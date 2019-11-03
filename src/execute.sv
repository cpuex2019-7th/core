`default_nettype none
`include "def.sv"

module execute
  (input wire clk,
   input wire        rstn,
     
   input wire        enabled,
   input             instructions instr,
   input             regvpair register,
   input             regvpair fregister,
  
   input             fwdregkv onestep_forwarding,
   input             fwdregkv twostep_forwarding,

   output wire       completed,
   output            instructions instr_n,
   output            regvpair register_n,
   output            regvpair fregister_n,

   output reg [31:0] result,
   output reg        is_jump_chosen,
   output reg [31:0] jump_dest);

   // internal state
   //////////////////////
   regvpair _register;
   regvpair _fregister;   

   // connection with ALU
   //////////////////////
   wire [31:0]       alu_result;
   wire              alu_completed;   
   alu _alu(.clk(clk),
            .rstn(rstn),
            .enabled(enabled),
      
            .instr(instr),
            .register(register_n),
            .onestep_forwarding(onestep_forwarding),
            .twostep_forwarding(twostep_forwarding),
      
            .completed(alu_completed),      
            .result(alu_result));
   
   wire [31:0]       fpu_result;   
   wire              fpu_completed;   
   fpu _fpu(.clk(clk),
            .rstn(rstn),
            .enabled(enabled),
      
            .instr(instr),
            .register(register_n),
            .fregister(fregister_n),
            .onestep_forwarding(onestep_forwarding),
            .twostep_forwarding(twostep_forwarding),

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
            _completed <= 0;

            register_n.rs1 <= (onestep_forwarding.enabled && onestep_forwarding.key == instr.rs1)? onestep_forwarding.value :
                             (twostep_forwarding.enabled && twostep_forwarding.key == instr.rs1)? twostep_forwarding.value : 
                             register.rs1;
            register_n.rs2 <= (onestep_forwarding.enabled && onestep_forwarding.key == instr.rs2)? onestep_forwarding.value :
                             (twostep_forwarding.enabled && twostep_forwarding.key == instr.rs2)? twostep_forwarding.value : 
                             register.rs2;
            fregister_n.rs1 <= (onestep_forwarding.fenabled && onestep_forwarding.key == instr.rs1)? onestep_forwarding.value :
                             (twostep_forwarding.fenabled && twostep_forwarding.key == instr.rs1)? twostep_forwarding.value : 
                             fregister.rs1;
            fregister_n.rs2 <= (onestep_forwarding.fenabled && onestep_forwarding.key == instr.rs2)? onestep_forwarding.value :
                              (twostep_forwarding.fenabled && twostep_forwarding.key == instr.rs2)? twostep_forwarding.value : 
                              fregister.rs2;            
         end else if ((instr.rv32f && fpu_completed) 
                      || (!instr.rv32f && alu_completed)) begin            
            result <= (instr.rv32f)? fpu_result:
                      alu_result;
            _completed <= 1;            
            
            is_jump_chosen <= (instr.jal 
                               || instr.jalr) 
              || (instr.is_conditional_jump && alu_result == 32'd1);
            
            jump_dest <= instr.jal? instr.pc + $signed(instr.imm):
                         instr.jalr? (rs1 + $signed(instr.imm)):// & ~(32b'0):
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
