`default_nettype none

module fsgnjx
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
      output wire [31:0] y,
      output wire        exception);

   wire s1 = x1[31:31];
   wire [7:0] e1 = x1[30:23];
   wire [22:0] m1 = x1[22:0];
   wire s2 = x2[31:31];
   wire [7:0] e2 = x2[30:23];
   wire [22:0] m2 = x2[22:0];
   wire nzm1 = |m1;
   wire nzm2 = |m2;
   wire sy = s1 ^ s2;
   assign y = (e1 == 8'd255 && nzm1) ? {s1,8'd255,1'b1,m1[21:0]} :
              (e2 == 8'd255 && nzm2) ? {s2,8'd255,1'b1,m2[21:0]} : // 片方がnanなら結果もnan
              {sy,e1,m1};
   assign exception = ((e1 == 8'd255 && nzm1) || (e2 == 8'd255 && nzm2)) ? 1'b1 : 1'b0;

endmodule                                                                         
`default_nettype wire