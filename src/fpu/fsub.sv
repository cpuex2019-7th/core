`default_nettype none

module fadd
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
      output wire [31:0] y,
      output wire        ovf);
   // 1
   wire s1 = x1[31:31];
   wire [7:0] e1 = x1[30:23];
   wire [22:0] m1 = x1[22:0];
   wire s2 = x2[31:31];
   wire [7:0] e2 = x2[30:23];
   wire [22:0] m2 = x2[22:0];
   // 2
   wire [24:0] m1a = (e1 == 8'b0) ? {2'b0,m1} : {2'b1,m1};
   wire [24:0] m2a = (e2 == 8'b0) ? {2'b0,m2} : {2'b1,m2};
   // 3
   wire [7:0] e1a = (e1 == 8'b0) ? 8'b1 : e1;
   wire [7:0] e2a = (e2 == 8'b0) ? 8'b1 : e2;
   // 4
   wire [7:0] e2ai = ~e2a;
   // 5
   wire [8:0] te = {1'b0,e1a}+{1'b0,e2ai};
   // 6
   wire ce = (te[8:8] == 1'b1) ? 1'b0 : 1'b1;
   wire [8:0] te1 = te[8:0] + 9'b1;
   wire [8:0] te2 = ~te[8:0];
   wire [7:0] tde = (te[8:8] == 1'b1) ? te1[7:0] : te2[7:0];
   // 7
   wire [4:0] de = (|(tde[7:5])) ? 5'd31 : tde[4:0];
   // 8
   wire sel = (de[4:0] > 5'b0) ? ce : (m1a > m2a) ? 1'b0 : 1'b1;
   // 9
   wire [24:0] ms = (sel == 1'b0) ? m1a : m2a;
   wire [24:0] mi = (sel == 1'b0) ? m2a : m1a;
   wire [7:0] es = (sel == 1'b0) ? e1a : e2a;
   // wire [7:0] ei = (sel == 1'b0) ? e2a : e1a;
   wire ss = (sel == 1'b0) ? s1 : s2;
   // 10
   wire [55:0] mie = {mi,31'b0};
   // 11
   wire [55:0] mia = mie >> de;
   // 12
   wire tstck = |(mia[28:0]);
   // 13
   wire [26:0] mye = (s1 == s2) ? {ms,2'b0} + mia[55:29] : {ms,2'b0} - mia[55:29];
   // 14
   wire [7:0] esi = es + 8'b1;
   // 15
   wire [7:0] eyd = (mye[26:26] == 1'b0) ? es : (esi == 8'd255) ? 8'd255 : esi;
   wire [26:0] myd = (mye[26:26] == 1'b0) ? mye : (esi == 8'd255) ? {2'b1,25'b0} : mye >> 1;
   wire stck = (mye[26:26] == 1'b0) ? tstck : (esi == 8'd255) ? 1'b0 : tstck | mye[0:0];
   // 16
   wire my1 = ~|myd[25:25];
   wire my2 = ~|myd[25:24];
   wire my3 = ~|myd[25:23];
   wire my4 = ~|myd[25:22];
   wire my5 = ~|myd[25:21];
   wire my6 = ~|myd[25:20];
   wire my7 = ~|myd[25:19];
   wire my8 = ~|myd[25:18];
   wire my9 = ~|myd[25:17];
   wire my10 = ~|myd[25:16];
   wire my11 = ~|myd[25:15];
   wire my12 = ~|myd[25:14];
   wire my13 = ~|myd[25:13];
   wire my14 = ~|myd[25:12];
   wire my15 = ~|myd[25:11];
   wire my16 = ~|myd[25:10];
   wire my17 = ~|myd[25:9];
   wire my18 = ~|myd[25:8];
   wire my19 = ~|myd[25:7];
   wire my20 = ~|myd[25:6];
   wire my21 = ~|myd[25:5];
   wire my22 = ~|myd[25:4];
   wire my23 = ~|myd[25:3];
   wire my24 = ~|myd[25:2];
   wire my25 = ~|myd[25:1];
   wire my26 = ~|myd[25:0];
   wire [4:0] se = {4'b0,my1} + {4'b0,my2} + {4'b0,my3} + {4'b0,my4} + {4'b0,my5} + {4'b0,my6} + {4'b0,my7} + {4'b0,my8} + {4'b0,my9} + {4'b0,my10} + {4'b0,my11} + {4'b0,my12} + {4'b0,my13} + {4'b0,my14} + {4'b0,my15} + {4'b0,my16} + {4'b0,my17} + {4'b0,my18} + {4'b0,my19} + {4'b0,my20} + {4'b0,my21} + {4'b0,my22} + {4'b0,my23} + {4'b0,my24} + {4'b0,my25} + {4'b0,my26};
   // 17
   wire [8:0] eyf = {1'b0,eyd} - {4'b0,se};
   // 18
   wire [7:0] eyr = (eyf[8:8] == 1'b0 && eyf > 1'b0) ? eyf[7:0] : 8'b0;
   wire [26:0] myf = (eyf[8:8] == 1'b0 && eyf > 1'b0) ? myd << se : myd << (eyd[4:0] - 5'b1);
   // 19
   wire [24:0] myr = ((myf[1:1] == 1'b1 && myf[0:0] == 1'b0 && stck == 1'b0 && myf[2:2] == 1'b1) || (myf[1:1] == 1'b1 && myf[0:0] == 1'b0 && s1 == s2 && stck == 1'b1) || (myf[1:1] == 1'b1 && myf[0:0] == 1'b1)) ? myf[26:2] + 25'b1 : myf[26:2];
   // 20
   wire [7:0] eyri = eyr + 8'b1;
   // 21
   wire [7:0] ey = (myr[24:24] == 1'b1) ? eyri : (|myr[23:0] == 1'b0) ? 8'b0 : eyr;
   wire [22:0] my = (myr[24:24] == 1'b1) ? 23'b0 : (|myr[23:0] == 1'b0) ? 23'b0 : myr[22:0];
   // 22
   wire sy = (ey == 8'b0 && my == 23'b0) ? s1 & s2 : ss;
   // 23
   wire nzm1 = |m1;
   wire nzm2 = |m2;
   assign y = (e1 == 8'd255 && e2 != 8'd255) ? {s1,8'd255,nzm1,m1[21:0]} :
              (e2 == 8'd255 && e1 != 8'd255 && nzm2) ? {~s2,8'd255,nzm2,m2[21:0]} : // fadd から変更(~s2)
              (e2 == 8'd255 && e1 != 8'd255) ? {s2,8'd255,nzm2,m2[21:0]} :
              (e1 == 8'd255 && e2 == 8'd255 && nzm1) ? {s1,8'd255,1'b1,m1[21:0]} : // fadd から変更(下の行と入れ替え)
              (e1 == 8'd255 && e2 == 8'd255 && nzm2) ? {~s2,8'd255,1'b1,m2[21:0]} : // fadd から変更(~s2)
              (e1 == 8'd255 && e2 == 8'd255 && s1 == s2) ? {s1,8'd255,23'b0} :
              (e1 == 8'd255 && e2 == 8'd255) ? {1'b1,8'd255,1'b1,22'b0} : {sy,ey,my};
   assign ovf = (e1 < 8'd255 && e2 < 8'd255 && ((mye[26:26] == 1'b1 && esi == 8'd255) || (myr[24:24] == 1'b1 && eyri == 8'd255))) ? 1'b1 : 1'b0;

endmodule

// fadd から追加
module fsub
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
      output wire [31:0] y,
      output wire        ovf);

   fadd u1(x1,{~x2[31:31],x2[30:0]},y,ovf);

endmodule                                                                         
`default_nettype wire