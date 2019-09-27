// mmu modoki

module mmu(
	       input wire        clk,
	       input wire        rstn,

	       // Bus for RAM
           ////////////
           // address read channel
	       output reg [31:0] mem_axi_araddr,
	       input wire        mem_axi_arready,
	       output reg        mem_axi_arvalid,

           // response channel
	       output reg        mem_axi_bready,
	       input wire [1:0]  mem_axi_bresp,
	       input wire        mem_axi_bvalid,

           // read data channel
	       input wire [31:0] mem_axi_rdata,
	       output reg        mem_axi_rready,
	       input wire [1:0]  mem_axi_rresp,
	       input wire        mem_axi_rvalid,

           // address write channel
	       output reg [31:0] mem_axi_awaddr,
	       input wire        mem_axi_awready,
	       output reg        mem_axi_awvalid,

           // data write channel
	       output reg [31:0] mem_axi_wdata,
	       input wire        mem_axi_wready,
	       output reg [3:0]  mem_axi_wstrb,
	       output reg        mem_axi_wvalid,

	       // Bus for UART (USB)
           //////////////
	       // Core
	       input wire [31:0] core_axi_araddr,
	       output reg        core_axi_arready,
	       input wire        core_axi_arvalid,

	       input wire        core_axi_bready,
	       output reg [1:0]  core_axi_bresp,
	       output reg        core_axi_bvalid,

	       output reg [31:0] core_axi_rdata,
	       input wire        core_axi_rready,
	       output reg [1:0]  core_axi_rresp,
	       output reg        core_axi_rvalid,

	       input wire [31:0] core_axi_awaddr,
	       output reg        core_axi_awready,
	       input wire        core_axi_awvalid,

	       input wire [31:0] core_axi_wdata,
	       output reg        core_axi_wready,
	       input wire [3:0]  core_axi_wstrb,
	       input wire        core_axi_wvalid);

   // bypass all the signals.
   // NOTE: those assignments will be deleted in the future XD
   assign mem_axi_araddr = core_axi_araddr;
   assign mem_axi_arready = core_axi_arready;
   assign mem_axi_arvalid = core_axi_arvalid;
   assign mem_axi_bready = core_axi_bready;
   assign mem_axi_bresp = core_axi_bresp;
   assign mem_axi_bvalid = core_axi_bvalid;
   assign mem_axi_rdata = core_axi_rdata;
   assign mem_axi_rready = core_axi_rready;
   assign mem_axi_rresp = core_axi_rresp;
   assign mem_axi_rvalid = core_axi_rvalid;
   assign  mem_axi_awaddr = core_axi_awaddr;
   assign mem_axi_awready = core_axi_awready;
   assign mem_axi_awvalid = core_axi_awvalid;
   assign mem_axi_wdata = core_axi_wdata;
   assign mem_axi_wready =  core_axi_wready;
   assign mem_axi_wstrb = core_axi_wstrb;
   assign mem_axi_wvalid = core_axi_wvalid ;   

   always @(posedge clk) begin
      // TODO: implemeent here in the future
   end
endmodule
