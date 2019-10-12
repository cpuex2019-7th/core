`default_nettype none

module regf
  (input wire         clk,
   input wire        rstn,
     
   input wire [4:0]  rs1,
   input wire [4:0]  rs2,

   output reg [31:0] rd1,
   output reg [31:0] rd2,

   input wire        w_enable,
   input wire [4:0]  w_addr,
   input wire [31:0] w_data,

   output reg [31:0] regs[32]);

   // initialize
   integer           i;
   initial begin
      for (i=0; i<32; i++) begin
         regs[i] <= 0;
      end
   end

   // main
   always @(posedge clk) begin
      if(rstn) begin
         // update rd1 and rd2 
         rd1 <= regs[rs1];
         rd2 <= regs[rs2];         

         // write w_data to w_addr
         if(w_enable) begin
            if(w_addr != 0) begin
               regs[w_addr] <= w_data;  
            end       
         end
      end
   end
endmodule

`default_nettype wire
