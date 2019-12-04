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
   output reg [31:0]  pc_n,
   output reg [31:0]  instr_raw,
   output reg         is_jump_predicted,
   output reg [31:0]  next_pc);

   reg               state;
   reg _completed;
   assign completed = _completed & !enabled;
   
   assign rom_addr = pc;

   wire _is_jump_predicted;   
   wire [31:0] _next_pc;   
   predictor _predictor(.instr_raw(rom_data),
                        .current_pc(pc),
                        .is_jump_predicted(_is_jump_predicted),
                        .next_pc(_next_pc))

   // initialize
   initial begin
      state <= 0;      
   end
   
   // main
   always @(posedge clk) begin
      if(rstn) begin
         if (enabled) begin
            state <= 0;
            _completed <= 0;
            pc_n <= pc;
         end else if (state == 0) begin
            state <= 1;            
         end else if (state == 1) begin
            state <= 0;
            
            _completed <= 1;
            instr_raw <= rom_data;
            is_jump_predicted <= _is_jump_predicted;
            next_pc <= _next_pc;            
         end
      end else begin
         state <= 0;
         
         _completed <= 0;
         pc_n <= 0;
         instr_raw <= 0;         
      end
   end
endmodule

`default_nettype wire
