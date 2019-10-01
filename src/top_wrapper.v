module core_wrapper
  (input wire clk, 
   input wire rstn,
   
   // Bus for MMU
   // address read channel
   output reg [31:0] axi_araddr,
   input wire        axi_arready,
   output reg        axi_arvalid,

   // response channel
   output reg        axi_bready,
   input wire [1:0]  axi_bresp,
   input wire        axi_bvalid,

   // read data channel
   input wire [31:0] axi_rdata,
   output reg        axi_rready,
   input wire [1:0]  axi_rresp,
   input wire        axi_rvalid,

   // address write channel
   output reg [31:0] axi_awaddr,
   input wire        axi_awready,
   output reg        axi_awvalid,

   // data write channel
   output reg [31:0] axi_wdata,
   input wire        axi_wready,
   output reg [3:0]  axi_wstrb,
   output reg        axi_wvalid);
   
   core _core(clk, rstn,
              axi_araddr, axi_arready, axi_arvalid, axi_bready, axi_bresp, axi_bvalid, axi_rdata, axi_rready, axi_rresp, axi_rvalid, axi_awaddr, axi_awready, axi_awvalid, axi_wdata, axi_wready, axi_wstrb, axi_wvalid);   
endmodule
