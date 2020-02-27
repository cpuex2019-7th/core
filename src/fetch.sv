`default_nettype none
`include "def.sv"

module fetch
  (input wire         clk,
   input wire         rstn,
   input wire         enabled,
   input wire [31:0]  pc,

   output wire [31:0] rom_addr,
   input wire [31:0]  rom_data,
  
   output wire        completed,
   output reg [31:0] pc_n,
   output wire [31:0] instr_raw);

   reg               state;
   reg _completed;
   assign completed = _completed & !enabled;
   
   assign rom_addr = pc;     
   assign instr_raw = rom_data;
   
   // initialize
   initial begin
      state <= 0;      
   end
   
   // main
   always @(posedge clk) begin
      if(rstn) begin
         if (enabled) begin
            state <= 0;
            _completed <= 1;
            pc_n <= pc;
         end
      end else begin
         state <= 0;
         
         _completed <= 0;
         pc_n <= 0;
      end
   end
endmodule

`default_nettype wire
