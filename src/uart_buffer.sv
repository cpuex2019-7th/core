`default_nettype none

module uart_buffer(
	               input wire         clk,
	               input wire         rstn,

	               // Bus for MMU
                   ////////////
	               input wire [3:0]   mmu_axi_araddr,
	               output reg         mmu_axi_arready,
	               input wire         mmu_axi_arvalid,
	               input wire [2:0]   mmu_axi_arprot, 

	               input wire         mmu_axi_bready,
	               output wire [1:0]  mmu_axi_bresp,
	               output wire        mmu_axi_bvalid,

	               output reg [31:0]  mmu_axi_rdata,
	               input wire         mmu_axi_rready,
	               output reg [1:0]   mmu_axi_rresp,
	               output reg         mmu_axi_rvalid,

	               input wire [3:0]   mmu_axi_awaddr,
	               output wire        mmu_axi_awready,
	               input wire         mmu_axi_awvalid,
	               input wire [2:0]   mmu_axi_awprot, 

	               input wire [31:0]  mmu_axi_wdata,
	               output wire        mmu_axi_wready,
	               input wire [3:0]   mmu_axi_wstrb,
	               input wire         mmu_axi_wvalid,

                   // Bus for UART
                   ////////////
	               output reg [3:0]   uart_axi_araddr,
	               input wire         uart_axi_arready,
	               output reg         uart_axi_arvalid,
	               output reg [2:0]   uart_axi_arprot, 

                   // response channel
	               output wire        uart_axi_bready,
	               input wire [1:0]   uart_axi_bresp,
	               input wire         uart_axi_bvalid,

                   // read data channel
	               input wire [31:0]  uart_axi_rdata,
	               output reg         uart_axi_rready,
	               input wire [1:0]   uart_axi_rresp,
	               input wire         uart_axi_rvalid,

                   // address write channel
	               output wire [3:0]  uart_axi_awaddr,
	               input wire         uart_axi_awready,
	               output wire        uart_axi_awvalid,
	               output wire [2:0]  uart_axi_awprot, 

                   // data write channel
	               output wire [31:0] uart_axi_wdata,
	               input wire         uart_axi_wready,
	               output wire [3:0]  uart_axi_wstrb,
	               output wire        uart_axi_wvalid);

   // bypass wires related to uart tx
   assign uart_axi_bready = mmu_axi_bready;
   assign mmu_axi_bresp = uart_axi_bresp;
   assign mmu_axi_bvalid = uart_axi_bvalid;
    
   assign uart_axi_awaddr = mmu_axi_awaddr;
   assign mmu_axi_awready = uart_axi_awready;
   assign  uart_axi_awvalid = mmu_axi_awvalid;
   assign uart_axi_awprot = mmu_axi_awprot;

   assign uart_axi_wdata = mmu_axi_wdata;
   assign mmu_axi_wready = uart_axi_wready;
   assign uart_axi_wstrb = mmu_axi_wstrb;
   assign uart_axi_wvalid = mmu_axi_wvalid;
   

   reg [3:0]                          state;
   localparam r_waiting_ready = 0;   
   localparam r_writing_ready = 1;   
   localparam r_waiting_data = 2;   
   localparam r_writing_data = 3;
   localparam r_waiting_uartlite_arready = 4;
   localparam r_waiting_uartlite_rvalid = 5;
   
   
   reg [7:0]                          buffer[2048];
   reg [10:0]   head_idx;
   reg [10:0]   tail_idx;
   wire         is_buffer_empty = (tail_idx - head_idx == 0);
   reg [3:0]                          addr_cache;   
   
   task init;
      begin
         mmu_axi_arready <= 1;
         mmu_axi_rvalid <= 0;
         
         uart_axi_arvalid <= 0;
         uart_axi_rready <= 0;

         head_idx <= 0;
         tail_idx <= 0;
         
         addr_cache <= 0;
         
         state <= r_waiting_ready;      
      end   endtask; // init
   
   initial begin
      init();      
   end
   
   // Reply to MMU
   /////////////
   always @(posedge clk) begin
      if(rstn) begin
         if (state == r_waiting_ready) begin
            if (mmu_axi_arvalid) begin
               mmu_axi_arready <= 0;               
               if(mmu_axi_araddr[3:0] == 4'h0 && !is_buffer_empty) begin
                  mmu_axi_rvalid <= 1;
                  head_idx <= head_idx + 1;                  
                  mmu_axi_rdata <= {24'b0, buffer[head_idx]};
                  mmu_axi_rresp <= 2'b00;                  
                  state <= r_writing_data;                  
               end else begin                              
                  uart_axi_arvalid <= 1;
                  uart_axi_araddr <= mmu_axi_araddr[3:0];
                  addr_cache <= mmu_axi_araddr[3:0];
                  uart_axi_arprot <= mmu_axi_arprot;                                    
                  state <= r_writing_ready;
               end               
            end else begin
               mmu_axi_arready <= 0;
               uart_axi_arvalid <= 1;
               uart_axi_araddr <= 4'b0;
               uart_axi_arprot <= 3'b0;               
               state <= r_waiting_uartlite_arready;
            end
         end else if (state == r_writing_ready) begin
            if(uart_axi_arready) begin
               uart_axi_arvalid <= 0;            
               uart_axi_rready <= 1;            
               state <= r_waiting_data;
            end
         end if (state == r_waiting_data) begin
            if (uart_axi_rvalid) begin
               uart_axi_rready <= 0;
               mmu_axi_rvalid <= 1;
               if (addr_cache == 4'h8) begin
                  mmu_axi_rdata <= {uart_axi_rdata[31:1], !is_buffer_empty | uart_axi_rdata[0]};
               end else begin
                  mmu_axi_rdata <= uart_axi_rdata;
               end
               mmu_axi_rresp <= uart_axi_rresp;   
               state <= r_writing_data;            
            end
         end if (state == r_writing_data) begin
            if(mmu_axi_rready) begin
               mmu_axi_rvalid <= 0;
               mmu_axi_arready <= 1;
               state <= r_waiting_ready;
            end
         end if (state == r_waiting_uartlite_arready) begin
            if(uart_axi_arready) begin
               uart_axi_arvalid <= 0;            
               uart_axi_rready <= 1;            
               state <= r_waiting_uartlite_rvalid;               
            end
         end if (state == r_waiting_uartlite_rvalid) begin
            if (uart_axi_rvalid) begin
               uart_axi_rready <= 0;
               if (uart_axi_rresp == 2'b00) begin
                  // if valid data exists
                  buffer[tail_idx] <= uart_axi_rdata[7:0];
                  tail_idx <= tail_idx + 1;
               end
               mmu_axi_arready <= 1;
               state <= r_waiting_ready;            
            end
         end
      end else begin // if (rstn)
         init();         
      end
   end      
endmodule
`default_nettype wire
