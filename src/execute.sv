`default_nettype none
`include "def.sv"

module execute
  (input wire clk,
   input wire         rstn,
     
   input wire         enabled,
   input              instructions instr,
   input              regvpair register,
   input              regvpair fregister,
  
   output wire        completed,
   output             instructions instr_n,
   output             regvpair register_n,
   output             regvpair fregister_n,

   output wire [31:0] result,
   output wire        is_jump_chosen,
   output wire [31:0] jump_dest);
   
   // connection with ALU
   //////////////////////
   wire [31:0]        alu_result;
   wire               alu_completed;   
   alu _alu(.clk(clk),
            .rstn(rstn),
            .enabled(enabled),
      
            .instr(instr),
            .register(register),
      
            .completed(alu_completed),      
            .result(alu_result));
   
   wire [31:0]        fpu_result;   
   wire               fpu_completed;   
   fpu _fpu(.clk(clk),
            .rstn(rstn),
            .enabled(enabled),
      
            .instr(instr),
            .register(register),
            .fregister(fregister),

            .completed(fpu_completed),
            .result(fpu_result));
   
   wire               _completed = ((instr_n.rv32f && fpu_completed) 
                                    || (!instr_n.rv32f && alu_completed));
   assign completed = _completed & !enabled;

   assign result = (instr_n.rv32f)? fpu_result:
                   alu_result;
   
   assign is_jump_chosen = ((instr_n.jal 
                             || instr_n.jalr) 
                            || (instr_n.is_conditional_jump && alu_result == 32'd1)); 
   
   assign jump_dest = instr_n.jal? instr_n.pc + $signed(instr_n.imm):
                      instr.jalr? (register_n.rs1 + $signed(instr_n.imm)):// & ~(32b'0):
                      (instr_n.is_conditional_jump && alu_result == 32'd1)? instr_n.pc + $signed(instr_n.imm):
                      0;
   
   
   // set flags
   //////////////////////
   always @(posedge clk) begin
      if (rstn) begin
         if (enabled) begin
            instr_n <= instr;
            register_n <= register;            
            fregister_n <= fregister;
         end
      end
   end  
endmodule // execute
`default_nettype none
