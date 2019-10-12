module core_wrapper
  (input wire clk, 
   input wire         rstn,
     
   output wire [31:0] pc,
   input wire [31:0]  instr_raw_from_mem, 
  
   // Bus for MMU
   // address read channel
   output wire [31:0] axi_araddr,
   input wire         axi_arready,
   output wire        axi_arvalid,
   output wire [2:0]  axi_arprot, 

   // response channel
   output wire        axi_bready,
   input wire [1:0]   axi_bresp,
   input wire         axi_bvalid,

   // read data channel
   input wire [31:0]  axi_rdata,
   output wire        axi_rready,
   input wire [1:0]   axi_rresp,
   input wire         axi_rvalid,

   // address write channel
   output wire [31:0] axi_awaddr,
   input wire         axi_awready,
   output wire        axi_awvalid,
   output wire [2:0]  axi_awprot, 

   // data write channel
   output wire [31:0] axi_wdata,
   input wire         axi_wready,
   output wire [3:0]  axi_wstrb,
   output wire        axi_wvalid,

   output wire [2:0]  debug_state,
   output wire [2:0]  debug_mem_state);
   
   core _core(.clk(clk), 
              .rstn(rstn),
      
              .pc(pc), 
              .instr_raw_from_mem(instr_raw_from_mem),
      
              .axi_araddr(axi_araddr), 
              .axi_arready(axi_arready), 
              .axi_arvalid(axi_arvalid),
              .axi_arprot(axi_arprot),
      
              .axi_bready(axi_bready),
              .axi_bresp(axi_bresp), 
              .axi_bvalid(axi_bvalid),
      
              .axi_rdata(axi_rdata), 
              .axi_rready(axi_rready), 
              .axi_rresp(axi_rresp),
              .axi_rvalid(axi_rvalid), 

              .axi_awaddr(axi_awaddr), 
              .axi_awready(axi_awready), 
              .axi_awvalid(axi_awvalid),
              .axi_awprot(axi_awprot),
      
              .axi_wdata(axi_wdata), 
              .axi_wready(axi_wready), 
              .axi_wstrb(axi_wstrb),
              .axi_wvalid(axi_wvalid),

              .debug_state(.debug_state),
              .debug_mem_state(.debug_mem_state));   
endmodule
