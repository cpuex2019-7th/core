`default_nettype none

module fetch
  (input wire clk,
   input wire         rstn,
   input wire [31:0]  pc,

   output reg [31:0] data);

   reg [7:0]          prog [0:31];
   
   initial begin
      prog[0] <= 8'h93;
      prog[1] <= 8'h02;
      prog[2] <= 8'h00;
      prog[3] <= 8'h00;
      
      prog[4] <= 8'h13;
      prog[5] <= 8'h03;      
      prog[6] <= 8'h00;      
      prog[7] <= 8'h00;
      
      prog[8] <= 8'h93;      
      prog[9] <= 8'h03;      
      prog[10] <= 8'ha0;
      prog[11] <= 8'h00;      

      prog[12] <= 8'h93;      
      prog[13] <= 8'h82;      
      prog[14] <= 8'h12;
      prog[15] <= 8'h00;      

      prog[16] <= 8'h33;      
      prog[17] <= 8'h03;      
      prog[18] <= 8'h53;
      prog[19] <= 8'h00;      

      prog[20] <= 8'h63;      
      prog[21] <= 8'h84;      
      prog[22] <= 8'h72;
      prog[23] <= 8'h00;      

      prog[24] <= 8'h6f;      
      prog[25] <= 8'hf0;      
      prog[26] <= 8'h1f;
      prog[27] <= 8'hff;            

      prog[28] <= 8'h33;      
      prog[29] <= 8'h05;      
      prog[30] <= 8'h03;
      prog[31] <= 8'h00;
   end      
   
   always @(posedge clk) begin
      data <= prog[pc];      
   end  
endmodule // fetch
