`default_nettype none

module feq
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
      output wire        y,
      output wire        exception);

   // 定義
   wire [7:0] e1 = x1[30:23];
   wire [22:0] m1 = x1[22:0];
   wire [7:0] e2 = x2[30:23];
   wire [22:0] m2 = x2[22:0];
   // x1とx2が等しいか判定
   wire yy = (x1 == x2) ? 1'b1 : 1'b0;
   // nanかどうかの判定
   wire nzm1 = |m1;
   wire nzm2 = |m2;
   assign y = (e2 == 8'd255 && nzm2) ? 1'b0 :
              (e1 == 8'd255 && nzm1) ? 1'b0 : // 片方がnanなら結果は0
              (e1 == 8'b0 && m1 == 8'b0 && e2 == 8'b0 && m2 == 8'b0) ? 1'b1 : // 両方0なら符号は無視
              yy;
   assign exception = (e2 == 8'd255 && nzm2) ? 1'b1 :
                  (e1 == 8'd255 && nzm1) ? 1'b1 : // 片方がnanならexception bitを立てる
                  1'b0;

endmodule                                                                         
`default_nettype wire