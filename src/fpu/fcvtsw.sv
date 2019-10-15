`default_nettype none

module fcvtsw
   (  input wire [31:0]  x,
      output wire [31:0] y);
   // 定義
   wire s = x[31:31];
   wire [31:0] m = (s) ? {1'b0,~x[30:0]} + 32'b1 : {1'b0,x[30:0]};
   // 何桁ずらすかを計算
   wire my0 = ~|m[31:0];
   wire my1 = ~|m[31:1];
   wire my2 = ~|m[31:2];
   wire my3 = ~|m[31:3];
   wire my4 = ~|m[31:4];
   wire my5 = ~|m[31:5];
   wire my6 = ~|m[31:6];
   wire my7 = ~|m[31:7];
   wire my8 = ~|m[31:8];
   wire my9 = ~|m[31:9];
   wire my10 = ~|m[31:10];
   wire my11 = ~|m[31:11];
   wire my12 = ~|m[31:12];
   wire my13 = ~|m[31:13];
   wire my14 = ~|m[31:14];
   wire my15 = ~|m[31:15];
   wire my16 = ~|m[31:16];
   wire my17 = ~|m[31:17];
   wire my18 = ~|m[31:18];
   wire my19 = ~|m[31:19];
   wire my20 = ~|m[31:20];
   wire my21 = ~|m[31:21];
   wire my22 = ~|m[31:22];
   wire my23 = ~|m[31:23];
   wire my24 = ~|m[31:24];
   wire my25 = ~|m[31:25];
   wire my26 = ~|m[31:26];
   wire my27 = ~|m[31:27];
   wire my28 = ~|m[31:28];
   wire my29 = ~|m[31:29];
   wire my30 = ~|m[31:30];
   wire my31 = ~|m[31:31];

   wire [5:0] se = {4'b0,my0}+{4'b0,my1}+{4'b0,my2}+{4'b0,my3}+{4'b0,my4}+{4'b0,my5}+{4'b0,my6}+{4'b0,my7}+{4'b0,my8}+{4'b0,my9}+{4'b0,my10}+{4'b0,my11}+{4'b0,my12}+{4'b0,my13}+{4'b0,my14}+{4'b0,my15}+{4'b0,my16}+{4'b0,my17}+{4'b0,my18}+{4'b0,my19}+{4'b0,my20}+{4'b0,my21}+{4'b0,my22}+{4'b0,my23}+{4'b0,my24}+{4'b0,my25}+{4'b0,my26}+{4'b0,my27}+{4'b0,my28}+{4'b0,my29}+{4'b0,my30}+{4'b0,my31};
   // myf[31]に1が来るようにシフトする
   wire [31:0] myf = m << se;

   // 偶数丸めを行う
   wire [24:0] myr = (myf[7:7] && (|myf[6:0] || myf[8:8])) ? {1'b0,myf[31:8]} + 25'b1 : myf[31:8];
   // 桁を合わせる
   wire [22:0] my = (myr[24:24]) ? 23'b0 : myr[22:0];
   // 指数部分を求める (0のときは指数部を0にする)
   wire [7:0] ey = (~|x) ? 8'b0 : (myr[24:24]) ? 8'd159 - {2'b0,se} : 8'd158 - {2'b0,se};

   assign y = {s,ey,my};

endmodule                                                                         
`default_nettype wire