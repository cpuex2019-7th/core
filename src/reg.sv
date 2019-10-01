module regf
  (input wire         clk,
   input wire        rstn,
   
   input wire [4:0]  rs1,
   input wire [4:0]  rs2,

   output reg [31:0]  rd1,
   output reg [31:0]  rd2,

   input wire        w_enable,
   input wire [4:0]  w_addr,
   input wire [31:0] w_data);

   reg [31:0]        regs[32];
   
   integer i;
   initial begin
      for (i=0; i<32; i++) begin
          regs[i] <= 0;
      end
   end
   
   always @(posedge clk) begin
         rd1 <= regs[rs1];
         rd2 <= regs[rs2];         

      if(w_enable) begin
         if(w_addr != 0) begin
             regs[w_addr] <= w_data;  
         end       
      end
   end
endmodule
