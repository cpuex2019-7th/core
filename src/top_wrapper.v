`default_nettype none

module core_wrapper
  (input wire clk, 
   input wire rstn);
   
   core _core(clk, rstn);   
endmodule
