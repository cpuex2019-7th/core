module core_wrapper
  (input wire clk, 
   input wire rstn,
   output wire test);
   
   core _core(clk, rstn, test);   
endmodule
