`default_nettype none
`include "def.sv"

module alu 
  (input wire        clk,
   input wire         rstn,
   input wire         enabled,
     
   input              instructions instr,
   input              regvpair register,
   input              fwdregkv forwarding,
  
   output reg         completed,
   output wire [31:0] result);
   
   wire [63:0]        mul_temp = $signed({{32{rs1[31]}}, rs1}) * $signed({{32{rs2[31]}}, rs2});
   wire [63:0]        mul_temp_hsu = $signed({{32{rs1[31]}}, rs1}) * $signed({32'b0, rs2});
   wire [63:0]        mul_temp_hu = $signed({32'b0, rs1}) * $signed({32'b0, rs2});
   
   wire [31:0]        rs1 = forwarding.enabled && forwarding.key == instr.rs1? forwarding.value : register.rs1;
   wire [31:0]        rs2 = forwarding.enabled && forwarding.key == instr.rs2? forwarding.value : register.rs2;
   
   wire _result =  ///// rv32i /////
   // lui, auipc
                    instr.lui? instr.imm:
                    instr.auipc? $signed(instr.imm) + instr.pc:
                    // jumps
                    instr.jal? instr.pc + 4:
                    instr.jalr? instr.pc + 4:
                    // conditional breaks
                    instr.beq? (rs1 == rs2):
                    instr.bne? (rs1 != rs2):
                    instr.blt? ($signed(rs1) < $signed(rs2)):
                    instr.bge? ($signed(rs1) >= $signed(rs2)):
                    instr.bltu? rs1 < rs2:
                    instr.bgeu? rs1 >= rs2:
                    // memory control
                    instr.lb? $signed({1'b0, rs1}) + $signed(instr.imm):
                    instr.lh? $signed({1'b0, rs1}) + $signed(instr.imm):
                    instr.lw? $signed({1'b0, rs1}) + $signed(instr.imm):
                    instr.lbu? $signed({1'b0, rs1}) + $signed(instr.imm):
                    instr.lhu? $signed({1'b0, rs1}) + $signed(instr.imm):
                    instr.sb? $signed({1'b0, rs1}) + $signed(instr.imm):
                    instr.sh? $signed({1'b0, rs1}) + $signed(instr.imm):
                    instr.sw? $signed({1'b0, rs1}) + $signed(instr.imm):
                    // arith instr.immediate
                    instr.addi? $signed(rs1) + $signed(instr.imm):
                    instr.slti? $signed(rs1) < $signed(instr.imm):
                    instr.sltiu? rs1 < instr.imm:
                    instr.xori? rs1 ^ instr.imm:
                    instr.ori? rs1 | instr.imm:
                    instr.andi? rs1 & instr.imm:
                    instr.slli? rs1 << instr.imm[4:0]:
                    instr.srli? rs1 >> instr.imm[4:0]:
                    instr.srai? $signed(rs1) << instr.imm[4:0]:           
                    // arith others
                    instr.add? $signed(rs1) + $signed(rs2):      
                    instr.sub? $signed(rs1) - $signed(rs2):
                    instr.sll? rs1 << rs2:                   
                    instr.slt? $signed(rs1) < $signed(rs2):
                    instr.sltu? $signed(rs1) < $signed(rs2):
                    instr.i_xor? rs1 ^ rs2:
                    instr.srl? rs1 >> rs2[4:0]:                   
                    instr.sra? $signed(rs1) >>> rs2[4:0]:     
                    instr.i_or? rs1 | rs2:
                    instr.i_and? rs1 & rs2:
                    ///// rv32m /////
                    // seems to be buggy; not fully tested yet.
                    instr.mul? mul_temp[31:0]:
                    instr.mulh? mul_temp[63:32]:
                    instr.mulhsu? mul_temp_hsu[63:32]:
                    instr.mulhu? mul_temp_hu[63:32]:
                    instr.div? $signed(rs1) / $signed(rs2):
                    instr.divu? rs1 / rs2:
                    instr.rem? $signed(rs1) % $signed(rs2):
                    instr.remu? rs1 % rs2:   
                    31'b0;
   
   always @(posedge clk) begin
      if (rstn) begin
         if (enabled) begin
            result <= _result;            
            completed <= 1;
         end
      end else begin
         completed <= 0;         
      end
   end
   
endmodule
`default_nettype wire
