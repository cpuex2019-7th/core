module mem(
           input wire                 clk,
           input wire                 rstn,

           input wire                 enabled,
           input                      instructions instr,
           input                      regvpair register,
           input                      regvpair fregister,

           input wire [31:0]          addr,

	       // Bus for RAM
           ////////////
           output reg [19-1:0] ram_addr,
           output wire                ram_clka,
           output reg [31:0]          ram_dina,
           input wire [31:0]          ram_douta,
           output reg                 ram_ena,
           output wire                ram_rsta,
           output reg [3:0]           ram_wea,
           
           // Bus for UART buffer
           // address read channel
           output reg [31:0]          uart_axi_araddr,
           input wire                 uart_axi_arready,
           output reg                 uart_axi_arvalid,
           output reg [2:0]           uart_axi_arprot, 

           // response channel
           output reg                 uart_axi_bready,
           input wire [1:0]           uart_axi_bresp,
           input wire                 uart_axi_bvalid,

           // read data channel
           input wire [31:0]          uart_axi_rdata,
           output reg                 uart_axi_rready,
           input wire [1:0]           uart_axi_rresp,
           input wire                 uart_axi_rvalid,

           // address write channel
           output reg [31:0]          uart_axi_awaddr,
           input wire                 uart_axi_awready,
           output reg                 uart_axi_awvalid,
           output reg [2:0]           uart_axi_awprot, 

           // data write channel
           output reg [31:0]          uart_axi_wdata,
           input wire                 uart_axi_wready,
           output reg [3:0]           uart_axi_wstrb,
           output reg                 uart_axi_wvalid,

           output wire                completed,
           output                     instructions instr_n,
           output reg [31:0]          result);
   
   reg                       _completed;   
   assign completed = _completed & !enabled;
   
   assign ram_clka = clk;
   assign ram_rsta = ~rstn;

   enum reg [4:0]                                            {
                                                              WAITING_REQ,
                                                              PROCESSING_UART,
                                                              PROCESSING_MEM
                                                              } mem_state;
   
   task init_ram;
      begin
         ram_addr <= 32'b0;
         ram_dina <= 32'b0;
         ram_ena <= 1'b0;
         ram_wea <= 4'b0;               
      end
   endtask

   task init_uart_axi;
      begin
         uart_axi_arvalid <= 0;         
         uart_axi_rready <= 0;
         
         uart_axi_awvalid <= 0;
         uart_axi_wvalid <= 0;
         uart_axi_bready <= 0;         
         
         uart_axi_arprot <= 3'b000;         
         uart_axi_awprot <= 3'b000;      
      end
   endtask
   
   task init;
      begin
         init_ram();
         init_uart_axi();         
      end
   endtask
   
   always @(posedge clk) begin
      if(rstn) begin
         if (state == WAITING_REQ && enabled) begin
            instr_n <= instr;
            result <= addr;            
            _completed <= 0;            
            
            if (instr.is_load) begin
               if (addr[31:24] == 8'h7F) begin
                  // UART (lbu)
                  state <= PROCESSING_UART;                  
                  uart_axi_arvalid <= 1;
                  uart_axi_araddr <= addr[3:0];
                  uart_axi_arprot <= 3'b000;                  
               end else begin
                  // MEM (lw or flw)
                  state <= PROCESSING_MEM;
                  ram_ena <= 1'b1;
                  ram_addr <= addr[19-1+4:4];
                  is_mem_write <= 1'b0;                  
               end
            end else if (instr.is_store) begin
               if (addr[31:24] == 8'h7F) begin
                  // UART (sb)
                  state <= PROCESSING_UART;
                  uart_axi_awvalid <= 1;
                  uart_axi_awaddr <= addr;
                  
                  uart_axi_wvalid <= 1;                  
                  uart_axi_wdata <= {24'b0, register.rs2[7:0]};
                  
                  uart_axi_wstrb <= 4'b0001;
               end else begin
                  // MEM (sw or fsw)
                  state <= PROCESSING_MEM;                  
                  ram_addr <= addr[19-1+4:4];                  
                  ram_wea <= 4'b1111;
                  ram_ena <= 1'b1;                  
                  ram_dina <= instr.sw? register.rs2:
                        instr.fsw? fregister.rs1:
                        32'b0;                  
               end
            end else begin
               _completed <= 1;               
            end
         end else if (mem_state == PROCESSING_UART) begin
            if (instr_n.is_store) begin // sb
               if (uart_axi_awvalid && uart_axi_awready) begin
                  uart_axi_awvalid <= 1'b0;              
               end
               if (uart_axi_wvalid && uart_axi_wready) begin
                  uart_axi_wvalid <= 1'b0;              
               end            
               if (!uart_axi_awvalid && !uart_axi_wvalid) begin
                  uart_axi_bready <= 1'b1;               
               end
               
               if (uart_axi_bready && uart_axi_bvalid) begin
                  uart_axi_bready <= 1'b0;

                  // we have to go back to normal state.
                  state <= WAITING_REQ;
                  init_uart_axi();                  
               end
            end else begin // lbu
               if (uart_axi_rvalid && uart_axi_rready) begin
                  uart_axi_rready <= 1'b0;

                  // we have to go back to normal state.
                  state <= WAITING_REQ;                  
                  result <= uart_axi_rdata;
                  init_uart_axi();       
               end
            end
         end else if (mem_state == PROCESSING_MEM) begin             
            state <= WAITING_REQ;
            _completed <= 1'b1;
        
            init_ram();            
            if (instr_n.is_load) begin
               result <= ram_douta;       
            end
         end
      end else begin 
         _completed <= 0;         
      end // else: !if(enabled)
   end
endmodule
