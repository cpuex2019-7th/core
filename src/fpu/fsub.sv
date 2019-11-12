`default_nettype none

module fsub
   (  input wire [31:0]  x1,
      input wire [31:0]  x2,
      output wire [31:0] y,
      output wire        ovf);

   fadd_intl u1(x1,{~x2[31:31],x2[30:0]},y,ovf);

endmodule                                                                         
`default_nettype wire
