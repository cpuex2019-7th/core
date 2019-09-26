`default_nettype none

module regf
  (input wire         clk,
   input wire        rstn,
   input wire [4:0]  rs1,
   input wire [4:0]  rs2,

   output wire [4:0] rd1,
   output wire [4:0] rd2,

   input wire        w_enable,
   input wire [4:0]  w_addr,
   input wire [31:0] w_data,  
   );

   reg [31:0]        regs[32];
   
   always @(psedge clk) begin
      if (!rstn) begin
      end else begin
         rs1 <= regs[rs1];
         rs2 <= regs[rs2];         
      end

      if(write_enable) begin
         regs[wa] <= wd;         
      end
   end
endmodule
