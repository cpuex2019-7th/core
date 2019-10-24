`default_nettype none
`include "def.sv"

module execute
  (input wire clk,
   input wire        rstn,

   // currernt state
   input wire [2:0]  state,

   // pc & decoded instr
   input wire [31:0] pc,
   input             instructions instr,

   // operands
   input wire [4:0]  rd,
  
   input wire [4:0]  rs1,
   input wire [31:0] rs1_v,
   input wire [31:0] frs1_v,
  
   input wire [4:0]  rs2,
   input wire [31:0] rs2_v,
   input wire [31:0] frs2_v,
  
   input wire [31:0] imm,

   // results
   output reg [31:0] result,
  
   output reg        mem_write_enabled,
   output reg        mem_read_enabled,
  
   output reg        reg_write_enabled,
   output reg [4:0]  reg_write_dest,
  
   output reg        freg_write_enabled,
   output reg [4:0]  freg_write_dest,

   output reg        is_jump_enabled,
   output reg [31:0] jump_dest);

   
   // connection with ALU
   //////////////////////
   wire [31:0]       alu_result;   
   alu _alu(.clk(clk),
            .rstn(rstn),
            .instr(instr),
            .pc(pc),
            .rs1_v(rs1_v), .rs2_v(rs2_v),
            .imm(imm),
            .result(alu_result));
   
   // set flags
   //////////////////////
   always @(posedge clk) begin
      if (rstn && state == EXEC) begin
         // memory read/write
         mem_read_enabled <= (instr.lb
                              || instr.lh
                              || instr.lw
                              || instr.lbu
                              || instr.lhu
                              || instr.flw);
         
         mem_write_enabled <= (instr.sb
                               || instr.sh
                               || instr.sw
                               || instr.fsw);         

         // integer register control flags
         reg_write_enabled <= !(instr.beq 
                                || instr.bne 
                                || instr.blt 
                                || instr.bge 
                                || instr.bltu 
                                || instr.bgeu
                                || instr.sb
                                || instr.sh
                                || instr.sw
                                || instr.fcvtws
                                || instr.fmvxw
                                || instr.feq
                                || instr.fle);         
         reg_write_dest <= rd;
         
         // floating-point register control flags
         freg_write_enabled <= (instr.flw
                                || instr.fadd 
                                || instr.fsub
                                || instr.fmul
                                || instr.fdiv
                                || instr.fsqrt
                                || instr.fsgnj
                                || instr.fsgnjn
                                || instr.fsgnjx
                                || instr.fcvtsw
                                || instr.fmvwx);         
         freg_write_dest <= rd;
         
         // control flags
         is_jump_enabled <= (instr.jal 
                             || instr.jalr 
                             || ((instr.beq 
                                  || instr.bne 
                                  ||  instr.blt
                                  || instr.bge
                                  || instr.bltu
                                  || instr.bgeu) 
                                 &&  (alu_result == 32'd1)));
         
         jump_dest <= instr.jal? pc + $signed(imm):
                      instr.jalr? (rs1_v + $signed(imm)):// & ~(32b'0):
                      (instr.beq 
                       || instr.bne 
                       || instr.blt 
                       || instr.bge 
                       || instr.bltu 
                       || instr.bgeu)? pc + $signed(imm):
                      32'b0;

         // what to write
         result <= alu_result;             
      end
   end  
endmodule // execute
`default_nettype none
