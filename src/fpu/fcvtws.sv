`default_nettype none

module fcvtws
   (  input wire [31:0]  x,
      output wire [31:0] y,
      output wire        exception);
   // 定義
   wire s = x[31:31];
   wire [7:0] e = x[30:23];
   wire [55:0] m = {31'b0,1'b1,x[22:0],1'b0};
   // 何桁ずらすかを計算
   wire [7:0] se = (e[7:7]) ? e - 8'd127 : 8'd127 - e;
   wire [55:0] myf = (e[7:7]) ? m << se : m >> se;

   // 四捨五入丸めを行う
   wire [31:0] myr = (myf[23:23]) ? myf[55:24] + 32'b1 : myf[55:24];
   // 負ならひっくり返す
   wire [31:0] my = (s) ? ~myr + 32'b1 : myr;

   assign y = my;
   // オーバーフロー or nan のときexception flagを立てる
   // intの負の最大値のときはflagを立てないように気をつける
   assign exception = (e[7:7] && se > 8'd30 && ~(s && e == 8'd158 && ~|x[22:0])) ? 1'b1 : 1'b0;

endmodule                                                                         
`default_nettype wire