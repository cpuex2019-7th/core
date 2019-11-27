`default_nettype none

module fsub
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
		input wire         clk,
		input wire         rstn,
		input wire         enable_in,
		output wire        enable_out,
      output wire [31:0] y,
      output wire        ovf);

   fadd u1(x1,{~x2[31:31],x2[30:0]},clk,rstn,enable_in,enable_out,y,ovf);

endmodule                                                                         
`default_nettype wire