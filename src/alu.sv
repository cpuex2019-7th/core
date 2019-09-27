`include "def.sv"

module alu 
  (input wire        clk,
   input wire         rstn,
     
   input              instructions instr,

   input wire [31:0]  rs1_v,
   input wire [31:0]  rs2_v,
   input wire [31:0]  imm,

   output wire [31:0] result

   );
   
   assign result = // lui, auipc
                   instr.lui? imm:
                   instr.auipc? 31'b0: // TODO: sign
                   // jumps
                   instr.jal? 31'b0:
                   instr.jalr? $signed(rs1_v) + $signed(imm):
                   // conditional breaks
                   instr.beq? (rs1_v == rs2_v):
                   instr.bne? (rs1_v != rs2_v):
                   instr.blt? ($signed(rs1_v) < $signed(rs2_v)):
                   instr.bge? ($signed(rs1_v) >= $signed(rs2_v)):
                   instr.bltu? rs1_v < rs2_v:
                   instr.bgeu? rs1_v >= rs2_v:
                   // memory control
                   instr.lb? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.lh? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.lw? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.lbu? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.lhu? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.sb? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.sh? $signed({1'b0, rs1_v}) + $signed(imm):
                   instr.sw? $signed({1'b0, rs1_v}) + $signed(imm):
                   // arith immediate
                   instr.addi? $signed(rs1_v) + $signed(imm):
                   instr.slti? $signed(rs1_v) < $signed(imm):
                   instr.sltiu? rs1_v < imm:
                   instr.xori? rs1_v ^ imm:
                   instr.ori? rs1_v | imm:
                   instr.andi? rs1_v & imm:
                   instr.slli? rs1_v << imm[4:0]:
                   instr.srli? rs1_v >> imm[4:0]:
                   instr.srai? $signed(rs1_v) << imm[4:0]:           
                   // arith others
                   instr.add? $signed(rs1_v) + $signed(rs2_v):      
                   instr.sub? $signed(rs1_v) - $signed(rs2_v):
                   instr.sll? rs1_v << rs2_v:                   
                   instr.slt? $signed(rs1_v) < $signed(rs2_v):
                   instr.sltu? $signed(rs1_v) < $signed(rs2_v):
                   instr.i_xor? rs1_v ^ rs2_v:
                   instr.srl? rs1_v >> rs2_v[4:0]:                   
                   instr.sra? $signed(rs1_v) >>> rs2_v[4:0]:     
                   instr.i_or? rs1_v | rs2_v:
                   instr.i_and? rs1_v & rs2_v:
                   31'b0;      
endmodule
