`default_nettype none
`include "def.sv"

module execute
  (input wire clk,
   input wire        rstn,
     
   input wire        enabled,
   input             instructions instr,
   input             regvpair register,
   input             regvpair fregister,

   output reg        completed,
   output            instructions instr_n,
   output            regvpair register_n,
   output            regvpair fregister_n,

   output reg [31:0] result,
   output reg        is_jump_chosen,
   output reg [31:0] next_pc);

   
   // connection with ALU
   //////////////////////
   wire [31:0]       alu_result;
   wire              alu_completed;   
   alu _alu(.clk(clk),
            .rstn(rstn),
      
            .instr(instr),
            .register(register),
      
            .completed(alu_completed),      
            .result(alu_result));
   
   wire [31:0]       fpu_result;   
   wire              fpu_completed;   
   fpu _fpu(.clk(clk),
            .rstn(rstn),
      
            .instr(instr),
            .register(register),
            .fregister(fregister),

            .completed(fpu_completed),
            .result(fpu_result));
   
   
   // set flags
   //////////////////////
   always @(posedge clk) begin
      if (rstn) begin
         if (enabled) begin
            result <= (instr.rv32f)? fpu_result:
                      alu_result;

            completed <= (instr.rv32f)? fpu_completed:
                         alu_completed;

            instr_n <= instr;
            register_n <= register;
            fregister_n <= fregister;
            
            is_jump_chosen <= (instr.jal 
                               || instr.jalr) 
              || (instr.is_conditional_jump &&  alu_result == 32'd1);
            
            next_pc <= instr.jal? instr.pc + $signed(instr.imm):
                       instr.jalr? (register.rs1 + $signed(instr.imm)):// & ~(32b'0):
                       (instr.is_conditional_jump && alu_result == 32'd1)? instr.pc + $signed(instr.imm):
                       instr.pc + 4;

         end
      end
   end  
endmodule // execute
`default_nettype none
