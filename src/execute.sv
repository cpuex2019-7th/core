`default_nettype none
`include "def.sv"

module execute
  (input wire clk,
   input wire        rstn,
     
   input wire        enabled,
   input             instructions instr,
   input             regvpair register,
   input             regvpair fregister,
  
   input             fwdregkv forwarding_from_exec,
   input             fwdregkv forwarding_from_mem,

   output wire       completed,
   output            instructions instr_n,
   output            regvpair register_n,
   output            regvpair fregister_n,

   output reg [31:0] result,
   output reg        is_jump_chosen,
   output reg [31:0] jump_dest);

   // connection with ALU
   //////////////////////
   wire [31:0]       alu_result;
   wire              alu_completed;   
   alu _alu(.clk(clk),
            .rstn(rstn),
            .enabled(enabled),
      
            .instr(instr),
            .register(register),
            .forwarding_from_exec(forwarding_from_exec),
            .forwarding_from_mem(forwarding_from_mem),
      
            .completed(alu_completed),      
            .result(alu_result));
   
   wire [31:0]       fpu_result;   
   wire              fpu_completed;   
   fpu _fpu(.clk(clk),
            .rstn(rstn),
            .enabled(enabled),
      
            .instr(instr),
            .register(register),
            .fregister(fregister),
            .forwarding_from_exec(forwarding_from_exec),
            .forwarding_from_mem(forwarding_from_mem),

            .completed(fpu_completed),
            .result(fpu_result));
   reg               _completed;
   assign completed = _completed & !enabled;
   
   // set flags
   //////////////////////
   always @(posedge clk) begin
      if (rstn) begin
         if (enabled) begin
            instr_n <= instr;
            register_n <= register;
            fregister_n <= fregister;
            _completed <= 0;            
         end else if ((instr.rv32f && fpu_completed) 
                      || (!instr.rv32f && alu_completed)) begin            
            result <= (instr.rv32f)? fpu_result:
                      alu_result;
            _completed <= 1;            
            
            is_jump_chosen <= (instr.jal 
                               || instr.jalr) 
              || (instr.is_conditional_jump && alu_result == 32'd1);
            
            jump_dest <= instr.jal? instr.pc + $signed(instr.imm):
                         instr.jalr? (register.rs1 + $signed(instr.imm)):// & ~(32b'0):
                         (instr.is_conditional_jump && alu_result == 32'd1)? instr.pc + $signed(instr.imm):
                         0;                        
         end else begin
            _completed <= 0;            
         end
      end else begin
         _completed <= 0;
      end
   end  
endmodule // execute
`default_nettype none
