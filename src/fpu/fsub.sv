`default_nettype none

module fadd_intl
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
   wire [4:0] se = (myd[25:25]) ? 5'd0 :
                   (myd[24:24]) ? 5'd1 :
                   (myd[23:23]) ? 5'd2 :
                   (myd[22:22]) ? 5'd3 :
                   (myd[21:21]) ? 5'd4 :
                   (myd[20:20]) ? 5'd5 :
                   (myd[19:19]) ? 5'd6 :
                   (myd[18:18]) ? 5'd7 :
                   (myd[17:17]) ? 5'd8 :
                   (myd[16:16]) ? 5'd9 :
                   (myd[15:15]) ? 5'd10 :
                   (myd[14:14]) ? 5'd11 :
                   (myd[13:13]) ? 5'd12 :
                   (myd[12:12]) ? 5'd13 :
                   (myd[11:11]) ? 5'd14 :
                   (myd[10:10]) ? 5'd15 :
                   (myd[9:9]) ? 5'd16 :
                   (myd[8:8]) ? 5'd17 :
                   (myd[7:7]) ? 5'd18 :
                   (myd[6:6]) ? 5'd19 :
                   (myd[5:5]) ? 5'd20 :
                   (myd[4:4]) ? 5'd21 :
                   (myd[3:3]) ? 5'd22 :
                   (myd[2:2]) ? 5'd23 :
                   (myd[1:1]) ? 5'd24 :
                   (myd[0:0]) ? 5'd25 : 5'd27;
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

   fadd_intl u1(x1,{~x2[31:31],x2[30:0]},y,ovf);

endmodule                                                                         
`default_nettype wire
