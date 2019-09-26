`default_nettype none

module fetch
  (input wire clk,
   input wire         rstn,
   input wire [31:0]  pc,

   output wire [31:0] data);

   reg [7:0]          prog [0:31];
   
   initial begin
      prog[0] <= 0x93;
      prog[1] <= 0x02;
      prog[2] <= 0x00;
      prog[3] <= 0x00;
      
      prog[4] <= 0x13;
      prog[5] <= 0x03;      
      prog[6] <= 0x00;      
      prog[7] <= 0x00;
      
      prog[8] <= 0x93;      
      prog[9] <= 0x03;      
      prog[10] <= 0xa0;
      prog[11] <= 0x00;      

      prog[12] <= 0x93;      
      prog[13] <= 0x82;      
      prog[14] <= 0x12;
      prog[15] <= 0x00;      

      prog[16] <= 0x33;      
      prog[17] <= 0x03;      
      prog[18] <= 0x53;
      prog[19] <= 0x00;      

      prog[20] <= 0x63;      
      prog[21] <= 0x84;      
      prog[22] <= 0x72;
      prog[23] <= 0x00;      

      prog[24] <= 0x6f;      
      prog[25] <= 0xf0;      
      prog[26] <= 0x1f;
      prog[27] <= 0xff;            

      prog[28] <= 0x33;      
      prog[29] <= 0x05;      
      prog[30] <= 0x03;
      prog[31] <= 0x00;
   end      
   
   always @(posedge clk) begin
      data <= prog[pc];      
   end  
endmodule // fetch
