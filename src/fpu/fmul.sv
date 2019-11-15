`default_nettype none

module fmul
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
      output wire [31:0] y,
      output wire        ovf);
   // 定義
   wire [7:0] e1 = x1[30:23];
   wire [7:0] e2 = x2[30:23];
   // mantissaの掛け算の計算
   wire [47:0] mye = {25'b1,x1[22:0]} * {25'b1,x2[22:0]};

   // &mye[47:23]なら2，mye[47] = 1, &mye[46:22] = 1, &mye[45:21] = 1なら1繰り上がる
   wire [9:0] ey = (mye[47:47] || &mye[46:22]) ? {2'b0,e1} + {2'b0,e2} - 10'd126 : {2'b0,e1} + {2'b0,e2} - 10'd127;
   wire [22:0] my = (mye[47:47]) ? ((&mye[46:23]) ? {23'b0} : (mye[23:23] && (mye[24:24] || |mye[22:0])) ? mye[46:24] + 23'b1 : mye[46:24]) :
                    ((&mye[45:22]) ? {23'b0} : (mye[22:22] && (mye[23:23] || |mye[21:0])) ? mye[45:23] + 23'b1 : mye[45:23]);

   // 符号を求める
   wire sy = x1[31:31] ^ x2[31:31];
   assign y = (~&e1 && ~&e2 && ~|ey && &mye[46:23]) ? {sy,8'b1,23'b0} : // 繰り上がりで指数部が1，仮数部が0になるとき
              (~&e1 && ~&e2 && (ey[9:9] || ~|ey)) ? {sy,31'b0} :
              (~&e1 && ~&e2 && ey[8:8]) ? {sy,8'd255,23'b0} : {sy,ey[7:0],my}; // overflowしたら符号を合わせて無限にする
   assign ovf = (~&e1 && ~&e2 && ~ey[9:9] && ey[8:8]) ? 1'b1 : 1'b0;

endmodule                                                                         
`default_nettype wire