`default_nettype none

module mmu # (parameter MEM_WIDTH = 21)(
	                                    input wire                 clk,
	                                    input wire                 rstn,

	                                    // Bus for RAM
                                        ////////////
                                        output reg [MEM_WIDTH-1:0] ram_addr,
                                        output wire                ram_clka,
                                        output reg [31:0]          ram_dina,
                                        input wire [31:0]          ram_douta,
                                        output reg                 ram_ena,
                                        output wire                ram_rsta,
                                        output reg [3:0]           ram_wea,

	                                    // Bus for Core
                                        ////////////
	                                    input wire [31:0]          core_axi_araddr,
	                                    output reg                 core_axi_arready,
	                                    input wire                 core_axi_arvalid,
	                                    input wire [2:0]           core_axi_arprot, 

	                                    input wire                 core_axi_bready,
	                                    output reg [1:0]           core_axi_bresp,
	                                    output reg                 core_axi_bvalid,

	                                    output reg [31:0]          core_axi_rdata,
	                                    input wire                 core_axi_rready,
	                                    output reg [1:0]           core_axi_rresp,
	                                    output reg                 core_axi_rvalid,

	                                    input wire [31:0]          core_axi_awaddr,
	                                    output reg                 core_axi_awready,
	                                    input wire                 core_axi_awvalid,
	                                    input wire [2:0]           core_axi_awprot, 

	                                    input wire [31:0]          core_axi_wdata,
	                                    output reg                 core_axi_wready,
	                                    input wire [3:0]           core_axi_wstrb,
	                                    input wire                 core_axi_wvalid,

                                        // Bus for UART
                                        ////////////
	                                    output reg [3:0]           uart_axi_araddr,
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
	                                    output reg [3:0]           uart_axi_awaddr,
	                                    input wire                 uart_axi_awready,
	                                    output reg                 uart_axi_awvalid,
	                                    output reg [2:0]           uart_axi_awprot, 

                                        // data write channel
	                                    output reg [31:0]          uart_axi_wdata,
	                                    input wire                 uart_axi_wready,
	                                    output reg [3:0]           uart_axi_wstrb,
	                                    output reg                 uart_axi_wvalid);

                                        // for debug
                                         reg [2:0]           reading_state;
                                         reg [2:0]           writing_state;

   assign ram_clka = clk;
   assign ram_rsta = ~rstn;

   enum reg [4:0]                                            {
                                                              WAITING_REQ,
                                                              PROCESSING_UART,
                                                              PROCESSING_MEM
                                                              } state;
   
   reg [31:0]                                                req_waddr;
   reg [31:0]                                                req_wdata;   
   reg [31:0]                                                req_wstrb;   

   task init_ram;
      begin
         ram_addr <= 32'b0;
         ram_dina <= 32'b0;
         ram_ena <= 1'b0;
         ram_wea <= 4'b0;               
      end
   endtask // init_ram

   task init_core_axi;
      begin
         core_axi_arready <= 1;
         core_axi_bvalid <= 0;
         core_axi_rvalid <= 0;
         core_axi_awready <= 1;
         core_axi_wready <= 1;   
      end
   endtask // init_core_axi

   task init_uart_axi;
      begin
         uart_axi_arvalid <= 0;
         uart_axi_rready <= 0;
         uart_axi_bready <= 0;
         uart_axi_awvalid <= 0;
         uart_axi_wvalid <= 0;
         uart_axi_arprot <= 3'b000;         
         uart_axi_awprot <= 3'b000;      
      end
   endtask
   
   task init;
      begin
         init_ram();
         init_core_axi();
         init_uart_axi();         
      end
   endtask
   
   always @(posedge clk) begin
      if(rstn) begin
         if (state == WAITING_REQ) begin
            if (core_axi_arvalid && core_axi_arready) begin
               core_axi_arready <= 0;
               
               if (core_axi_araddr[31:24] == 8'h7F) begin
                  // UART
                  state <= PROCESSING_UART;                  
                  uart_axi_arvalid <= 1;
                  uart_axi_araddr <= core_axi_araddr[3:0];
                  uart_axi_arprot <= core_axi_arprot;
               end else begin
                  // MEM
                  state <= PROCESSING_MEM;
                  ram_ena <= 1'b1;
                  ram_addr <= core_axi_araddr[MEM_WIDTH-1:0];                  
               end               
            end 

            if (core_axi_awvalid && core_axi_awready) begin
               core_axi_awready <= 1'b0;               
               req_waddr <= core_axi_waddr;               
            end            

            if (core_axi_wvalid && core_axi_wready) begin
               core_axi_wready <= 1'b0;
               req_wdata <= core_axi_wdata;               
               req_wstrb <= core_axi_wstrb;               
            end

            if (!core_axi_awready && !core_axi_wready) begin
               if (req_waddr[31:24] == 8'h7F) begin
                  // UART
                  state <= PROCESSING_UART;
                  uart_axi_awvalid <= 1;
                  uart_axi_awaddr <= req_waddr;                  
                  uart_axi_wvalid <= 1;                  
                  uart_axi_wdata <= req_wdata;
                  uart_axi_wstrb <= req_wstrb;
               end else begin
                  // MEM
                  state <= WAITING_MEM;
                  ram_addr <= req_waddr[MEM_WIDTH-1:0];                  
                  ram_dina <= req_wdata;
                  ram_wea <= req_wstrb;
                  ram_ena <= 1'b1;                  
               end
            end
         end else if (state == PROCESSING_UART) begin
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
               
               core_axi_bvalid <= 1'b1;
               core_axi_bresp <= uart_axi_bresp;
            end
            if (core_axi_bvalid && core_axi_bready) begin
               core_axi_bvalid <= 1'b0;

               // back to normal state
               state <= WAITING_REQ;
               init_core_axi();               
            end
         end else if (state == WAITING_MEM) begin 
            // bram do all operation in 1 clock
            state <= PROCESSING_MEM;            
            init_ram();            
         end
      end else begin
         init();         
      end      
   end    
endmodule
`default_nettype wire
