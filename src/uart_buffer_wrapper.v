`default_nettype none

module uart_buffer_wrapper(
	                       input wire         clk,
	                       input wire         rstn,

	                       // Bus for MMU
                           ////////////
	                       input wire [3:0]   mmu_axi_araddr,
	                       output wire        mmu_axi_arready,
	                       input wire         mmu_axi_arvalid,
	                       input wire [2:0]   mmu_axi_arprot, 

	                       input wire         mmu_axi_bready,
	                       output wire [1:0]  mmu_axi_bresp,
	                       output wire        mmu_axi_bvalid,

	                       output wire [31:0] mmu_axi_rdata,
	                       input wire         mmu_axi_rready,
	                       output wire [1:0]  mmu_axi_rresp,
	                       output wire        mmu_axi_rvalid,

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
	                       output wire [3:0]  uart_axi_araddr,
	                       input wire         uart_axi_arready,
	                       output wire        uart_axi_arvalid,
	                       output wire [2:0]  uart_axi_arprot, 

                           // response channel
	                       output wire        uart_axi_bready,
	                       input wire [1:0]   uart_axi_bresp,
	                       input wire         uart_axi_bvalid,

                           // read data channel
	                       input wire [31:0]  uart_axi_rdata,
	                       output wire        uart_axi_rready,
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

   uart_buffer _uart_buffer(.clk(clk), .rstn(rstn),
                            // mmu
                            .mmu_axi_araddr(mmu_axi_araddr), 
                            .mmu_axi_arready(mmu_axi_arready), 
                            .mmu_axi_arvalid(mmu_axi_arvalid), 
                            .mmu_axi_arprot(mmu_axi_arprot),
      
                            .mmu_axi_bready(mmu_axi_bready), 
                            .mmu_axi_bresp(mmu_axi_bresp), 
                            .mmu_axi_bvalid(mmu_axi_bvalid),
      
                            .mmu_axi_rdata(mmu_axi_rdata), 
                            .mmu_axi_rready(mmu_axi_rready),
                            .mmu_axi_rresp(mmu_axi_rresp), 
                            .mmu_axi_rvalid(mmu_axi_rvalid),
      
                            .mmu_axi_awaddr(mmu_axi_awaddr), 
                            .mmu_axi_awready(mmu_axi_awready), 
                            .mmu_axi_awvalid(mmu_axi_awvalid), 
                            .mmu_axi_awprot(mmu_axi_awprot), 

                            .mmu_axi_wdata(mmu_axi_wdata), 
                            .mmu_axi_wready(mmu_axi_wready), 
                            .mmu_axi_wstrb(mmu_axi_wstrb), 
                            .mmu_axi_wvalid(mmu_axi_wvalid),
      
                            // uart
                            .uart_axi_araddr(uart_axi_araddr), 
                            .uart_axi_arready(uart_axi_arready), 
                            .uart_axi_arvalid(uart_axi_arvalid), 
                            .uart_axi_arprot(uart_axi_arprot),
      
                            .uart_axi_bready(uart_axi_bready), 
                            .uart_axi_bresp(uart_axi_bresp), 
                            .uart_axi_bvalid(uart_axi_bvalid),
      
                            .uart_axi_rdata(uart_axi_rdata), 
                            .uart_axi_rready(uart_axi_rready),
                            .uart_axi_rresp(uart_axi_rresp), 
                            .uart_axi_rvalid(uart_axi_rvalid),
      
                            .uart_axi_awaddr(uart_axi_awaddr), 
                            .uart_axi_awready(uart_axi_awready), 
                            .uart_axi_awvalid(uart_axi_awvalid), 
                            .uart_axi_awprot(uart_axi_awprot), 

                            .uart_axi_wdata(uart_axi_wdata), 
                            .uart_axi_wready(uart_axi_wready), 
                            .uart_axi_wstrb(uart_axi_wstrb), 
                            .uart_axi_wvalid(uart_axi_wvalid));
endmodule
`default_nettype wire
