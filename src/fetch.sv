`default_nettype none

module fetch
  (input wire clk,
   input wire         rstn,
   input wire [31:0]  pc,

   output wire [31:0] data);

   reg [7:0]          prog [0:31];
   
   initial begin
      prog[0] <= 8'x93;
      prog[1] <= 8'x02;
      prog[2] <= 8'x00;
      prog[3] <= 8'x00;
      
      prog[4] <= 8'x13;
      prog[5] <= 8'x03;      
      prog[6] <= 8'x00;      
      prog[7] <= 8'x00;
      
      prog[8] <= 8'x93;      
      prog[9] <= 8'x03;      
      prog[10] <= 8'xa0;
      prog[11] <= 8'x00;      

      prog[12] <= 8'x93;      
      prog[13] <= 8'x82;      
      prog[14] <= 8'x12;
      prog[15] <= 8'x00;      

      prog[16] <= 8'x33;      
      prog[17] <= 8'x03;      
      prog[18] <= 8'x53;
      prog[19] <= 8'x00;      

      prog[20] <= 8'x63;      
      prog[21] <= 8'x84;      
      prog[22] <= 8'x72;
      prog[23] <= 8'x00;      

      prog[24] <= 8'x6f;      
      prog[25] <= 8'xf0;      
      prog[26] <= 8'x1f;
      prog[27] <= 8'xff;            

      prog[28] <= 8'x33;      
      prog[29] <= 8'x05;      
      prog[30] <= 8'x03;
      prog[31] <= 8'x00;
   end      
   
   always @(posedge clk) begin
      data <= prog[pc];      
   end  
endmodule // fetch
