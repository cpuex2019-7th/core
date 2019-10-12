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
   
   input wire [4:0]  rs2,
   input wire [31:0] rs2_v,
   
   input wire [31:0] imm,

   // results
   output reg [31:0] result,
  
   output reg        mem_write_enabled,
   output reg        mem_read_enabled,
  
   output reg        reg_write_enabled,
   output reg [4:0]  reg_write_dest,

   output reg        is_jump_enabled,
   output reg [31:0] jump_dest);

   
   // connection with ALU
   //////////////////////
   wire [31:0]       alu_result;   
   alu _alu(.clk(clk),
            .rstn(rstn),
            .instr(instr),
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
                               || instr.lhu);
      
         mem_write_enabled <= (instr.sb
                               || instr.sh
                               || instr.sw);         

         // register control flags
         reg_write_enabled <= !(instr.beq 
                                || instr.bne 
                                || instr.blt 
                                || instr.bge 
                                || instr.bltu 
                                || instr.bgeu);      
         reg_write_dest <= (instr.sb 
                            || instr.sh 
                            || instr.sw) ? rs2 : rd;
         
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
         
         jump_dest <= (instr.jalr)? alu_result:
                      pc + imm;

         // what to write
         result <= instr.jal? pc + 4  :
                   instr.auipc? pc + imm :
                   alu_result;         
      end else begin
         mem_write_enabled <= 0;
         reg_write_enabled <= 0;
         is_jump_enabled <= 0;         
      end
   end  
endmodule // execute
