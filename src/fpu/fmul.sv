`default_nettype none

module fmul
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
      output wire [31:0] y,
      output wire        ovf);
   // 定義
   wire s1 = x1[31:31];
   wire [7:0] e1 = x1[30:23];
   wire [22:0] m1 = x1[22:0];
   wire s2 = x2[31:31];
   wire [7:0] e2 = x2[30:23];
   wire [22:0] m2 = x2[22:0];
   // 非正規化数の処理
   wire [23:0] m1a = (e1 == 8'b0) ? {1'b0,m1} : {1'b1,m1};
   wire [23:0] m2a = (e2 == 8'b0) ? {1'b0,m2} : {1'b1,m2};
   wire [7:0] e1a = (e1 == 8'b0) ? 8'b1 : e1;
   wire [7:0] e2a = (e2 == 8'b0) ? 8'b1 : e2;
   // mantissaの掛け算の計算
   wire [47:0] mye = {24'b0,m1a} * {24'b0,m2a};
   // 何桁ずらすかを計算
   wire my0 = ~|mye[47:0];
   wire my1 = ~|mye[47:1];
   wire my2 = ~|mye[47:2];
   wire my3 = ~|mye[47:3];
   wire my4 = ~|mye[47:4];
   wire my5 = ~|mye[47:5];
   wire my6 = ~|mye[47:6];
   wire my7 = ~|mye[47:7];
   wire my8 = ~|mye[47:8];
   wire my9 = ~|mye[47:9];
   wire my10 = ~|mye[47:10];
   wire my11 = ~|mye[47:11];
   wire my12 = ~|mye[47:12];
   wire my13 = ~|mye[47:13];
   wire my14 = ~|mye[47:14];
   wire my15 = ~|mye[47:15];
   wire my16 = ~|mye[47:16];
   wire my17 = ~|mye[47:17];
   wire my18 = ~|mye[47:18];
   wire my19 = ~|mye[47:19];
   wire my20 = ~|mye[47:20];
   wire my21 = ~|mye[47:21];
   wire my22 = ~|mye[47:22];
   wire my23 = ~|mye[47:23];
   wire my24 = ~|mye[47:24];
   wire my25 = ~|mye[47:25];
   wire my26 = ~|mye[47:26];
   wire my27 = ~|mye[47:27];
   wire my28 = ~|mye[47:28];
   wire my29 = ~|mye[47:29];
   wire my30 = ~|mye[47:30];
   wire my31 = ~|mye[47:31];
   wire my32 = ~|mye[47:32];
   wire my33 = ~|mye[47:33];
   wire my34 = ~|mye[47:34];
   wire my35 = ~|mye[47:35];
   wire my36 = ~|mye[47:36];
   wire my37 = ~|mye[47:37];
   wire my38 = ~|mye[47:38];
   wire my39 = ~|mye[47:39];
   wire my40 = ~|mye[47:40];
   wire my41 = ~|mye[47:41];
   wire my42 = ~|mye[47:42];
   wire my43 = ~|mye[47:43];
   wire my44 = ~|mye[47:44];
   wire my45 = ~|mye[47:45];
   wire my46 = ~|mye[47:46];
   wire my47 = ~|mye[47:47];
   wire [5:0] se = {5'b0,my0}+{5'b0,my1}+{5'b0,my2}+{5'b0,my3}+{5'b0,my4}+{5'b0,my5}+{5'b0,my6}+{5'b0,my7}+{5'b0,my8}+{5'b0,my9}+{5'b0,my10}+{5'b0,my11}+{5'b0,my12}+{5'b0,my13}+{5'b0,my14}+{5'b0,my15}+{5'b0,my16}+{5'b0,my17}+{5'b0,my18}+{5'b0,my19}+{5'b0,my20}+{5'b0,my21}+{5'b0,my22}+{5'b0,my23}+{5'b0,my24}+{5'b0,my25}+{5'b0,my26}+{5'b0,my27}+{5'b0,my28}+{5'b0,my29}+{5'b0,my30}+{5'b0,my31}+{5'b0,my32}+{5'b0,my33}+{5'b0,my34}+{5'b0,my35}+{5'b0,my36}+{5'b0,my37}+{5'b0,my38}+{5'b0,my39}+{5'b0,my40}+{5'b0,my41}+{5'b0,my42}+{5'b0,my43}+{5'b0,my44}+{5'b0,my45}+{5'b0,my46}+{5'b0,my47};

   // myft[47]に1が来るように左シフト
   wire [47:0] myft = mye << se;
   // seが0のとき1繰り上がり，そうでないときはse-1繰り下がる
   wire [9:0] eyrt = {2'b0,e1a} + {2'b0,e2a} - {4'b0,se} - 10'd126;
   wire [7:0] eyr = (eyrt[9:9]) ? 8'b0 : (eyrt[8:8]) ? 8'd255 : eyrt[7:0];
   // eyri = eyr + 1
   wire [9:0] eyrit = eyrt + 10'b1;
   wire [7:0] eyri = (eyrit[9:9]) ? 8'b0 : (eyrit[8:8]) ? 8'd255 : eyrit[7:0];
   // eyrtが負のとき正規化するためにmyeをss右シフト，その他のときはそのまま
   // myft[69:47]がmantissa，myft[46:0]が切り捨てられる部分
   wire [9:0] ss = ~eyrt + 10'd2;
   wire [70:0] myf = (eyrt[9:9]) ? {myft,23'b0} >> ss[7:0] : (~|eyrt) ? {myft,23'b0} >> 1'b1 : {myft,23'b0};
   
   // 偶数丸めを行う
   // 切り上げるのは myf[46]が1かつ(myf[45:0]が0より大きいとき または myf[47]が1のとき)
   wire [24:0] myr = (myf[46:46] && (|myf[45:0] || myf[47:47])) ? {1'b0,myf[70:47]} + 25'b1 : {1'b0,myf[70:47]};
   // もう一度丸める
   wire [7:0] ey = (myr[24:24] == 1'b1) ? eyri : (myr[23:23] && ~|eyr) ? 8'b1 : (|myr[23:0] == 1'b0) ? 8'b0 : eyr;
   wire [22:0] my = (myr[24:24] == 1'b1) ? 23'b0 : (myr[23:23] && ~|eyr) ? {myr[21:0],1'b0} : myr[22:0];
   // 符号を求める
   wire sy = s1 ^ s2;
   // nanかどうかの判定
   wire nzm1 = |m1;
   wire nzm2 = |m2;
   assign y = (e2 == 8'd255 && nzm2) ? {s2,8'd255,1'b1,m2[21:0]} :
              (e1 == 8'd255 && nzm1) ? {s1,8'd255,1'b1,m1[21:0]} : // 片方がnanなら結果もnan
              (e1 == 8'd255 && e2 == 8'd0 && ~nzm2) ? {1'b1,8'd255,1'b1,m1[21:0]} :
              (e2 == 8'd255 && e1 == 8'd0 && ~nzm1) ? {1'b1,8'd255,1'b1,m2[21:0]} : // 0*infなら-nan
              (e1 == 8'd255 || e2 == 8'd255) ? {sy,8'd255,23'b0} : // 両方無限なら符号を合わせて無限にする
              (e1 < 8'd255 && e2 < 8'd255 && ey == 8'd255) ? {sy,8'd255,23'b0} : {sy,ey,my}; // overflowしたら符号を合わせて無限にする
   assign ovf = (e1 < 8'd255 && e2 < 8'd255 && ey == 8'd255) ? 1'b1 : 1'b0;

endmodule                                                                         
`default_nettype wire