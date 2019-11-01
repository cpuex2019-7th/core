`default_nettype none

module mmu_wrapper #
  (parameter MEM_WIDTH = 21)(
	                         input wire                  clk,
	                         input wire                  rstn,

	                         // Bus for RAM
                             ////////////
                             // address read channel
	                         output wire [MEM_WIDTH-1:0] mem_axi_araddr,
	                         input wire                  mem_axi_arready,
	                         output wire                 mem_axi_arvalid,
	                         output wire [2:0]           mem_axi_arprot, 

                             // response channel
	                         output wire                 mem_axi_bready,
	                         input wire [1:0]            mem_axi_bresp,
	                         input wire                  mem_axi_bvalid,

                             // read data channel
	                         input wire [31:0]           mem_axi_rdata,
	                         output wire                 mem_axi_rready,
	                         input wire [1:0]            mem_axi_rresp,
	                         input wire                  mem_axi_rvalid,

                             // address write channel
	                         output wire [MEM_WIDTH-1:0] mem_axi_awaddr,
	                         input wire                  mem_axi_awready,
	                         output wire                 mem_axi_awvalid,
	                         output wire [2:0]           mem_axi_awprot,

                             // data write channel
	                         output wire [31:0]          mem_axi_wdata,
	                         input wire                  mem_axi_wready,
	                         output wire [3:0]           mem_axi_wstrb,
	                         output wire                 mem_axi_wvalid,

	                         // Bus for Core
                             ////////////
	                         input wire [31:0]           core_axi_araddr,
	                         output wire                 core_axi_arready,
	                         input wire                  core_axi_arvalid,
	                         input wire [2:0]            core_axi_arprot, 

	                         input wire                  core_axi_bready,
	                         output wire [1:0]           core_axi_bresp,
	                         output wire                 core_axi_bvalid,

	                         output wire [31:0]          core_axi_rdata,
	                         input wire                  core_axi_rready,
	                         output wire [1:0]           core_axi_rresp,
	                         output wire                 core_axi_rvalid,

	                         input wire [31:0]           core_axi_awaddr,
	                         output wire                 core_axi_awready,
	                         input wire                  core_axi_awvalid,
	                         input wire [2:0]            core_axi_awprot, 

	                         input wire [31:0]           core_axi_wdata,
	                         output wire                 core_axi_wready,
	                         input wire [3:0]            core_axi_wstrb,
	                         input wire                  core_axi_wvalid,

                             // Bus for UART
                             ////////////
	                         output wire [3:0]           uart_axi_araddr,
	                         input wire                  uart_axi_arready,
	                         output wire                 uart_axi_arvalid,
	                         output wire [2:0]           uart_axi_arprot, 

                             // response channel
	                         output wire                 uart_axi_bready,
	                         input wire [1:0]            uart_axi_bresp,
	                         input wire                  uart_axi_bvalid,

                             // read data channel
	                         input wire [31:0]           uart_axi_rdata,
	                         output wire                 uart_axi_rready,
	                         input wire [1:0]            uart_axi_rresp,
	                         input wire                  uart_axi_rvalid,

                             // address write channel
	                         output wire [3:0]           uart_axi_awaddr,
	                         input wire                  uart_axi_awready,
	                         output wire                 uart_axi_awvalid,
	                         output wire [2:0]           uart_axi_awprot, 

                             // data write channel
	                         output wire [31:0]          uart_axi_wdata,
	                         input wire                  uart_axi_wready,
	                         output wire [3:0]           uart_axi_wstrb,
	                         output wire                 uart_axi_wvalid,

                             // for debug
                             output wire [2:0]           reading_state,
                             output wire [2:0]           writing_state);             

   mmu #(.MEM_WIDTH(MEM_WIDTH)) _mmu(.clk(clk), .rstn(rstn),
                                     
                                     // mem
                                     .mem_axi_araddr(mem_axi_araddr), 
                                     .mem_axi_arready(mem_axi_arready), 
                                     .mem_axi_arvalid(mem_axi_arvalid), 
                                     .mem_axi_arprot(mem_axi_arprot),
                                     
                                     .mem_axi_bready(mem_axi_bready), 
                                     .mem_axi_bresp(mem_axi_bresp), 
                                     .mem_axi_bvalid(mem_axi_bvalid),
                                     
                                     .mem_axi_rdata(mem_axi_rdata), 
                                     .mem_axi_rready(mem_axi_rready),
                                     .mem_axi_rresp(mem_axi_rresp), 
                                     .mem_axi_rvalid(mem_axi_rvalid),
                                     
                                     .mem_axi_awaddr(mem_axi_awaddr), 
                                     .mem_axi_awready(mem_axi_awready), 
                                     .mem_axi_awvalid(mem_axi_awvalid), 
                                     .mem_axi_awprot(mem_axi_awprot), 

                                     .mem_axi_wdata(mem_axi_wdata), 
                                     .mem_axi_wready(mem_axi_wready), 
                                     .mem_axi_wstrb(mem_axi_wstrb), 
                                     .mem_axi_wvalid(mem_axi_wvalid),

                                     // core
                                     .core_axi_araddr(core_axi_araddr), 
                                     .core_axi_arready(core_axi_arready), 
                                     .core_axi_arvalid(core_axi_arvalid), 
                                     .core_axi_arprot(core_axi_arprot),
                                     
                                     .core_axi_bready(core_axi_bready), 
                                     .core_axi_bresp(core_axi_bresp), 
                                     .core_axi_bvalid(core_axi_bvalid),
                                     
                                     .core_axi_rdata(core_axi_rdata), 
                                     .core_axi_rready(core_axi_rready),
                                     .core_axi_rresp(core_axi_rresp), 
                                     .core_axi_rvalid(core_axi_rvalid),
                                     
                                     .core_axi_awaddr(core_axi_awaddr), 
                                     .core_axi_awready(core_axi_awready), 
                                     .core_axi_awvalid(core_axi_awvalid), 
                                     .core_axi_awprot(core_axi_awprot), 

                                     .core_axi_wdata(core_axi_wdata), 
                                     .core_axi_wready(core_axi_wready), 
                                     .core_axi_wstrb(core_axi_wstrb), 
                                     .core_axi_wvalid(core_axi_wvalid),
                                     
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
