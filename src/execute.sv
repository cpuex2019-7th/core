`include "def.sv"

module execute
  (input wire clk,
   input wire        rstn,
   input wire [2:0]  state,

   input wire [31:0] pc,
   input             instructions instr,
  
   input wire [4:0]  rd,
   input wire [4:0]  rs1, // for future use (required in forwarding)
   input wire [31:0] rs1_v,
   input wire [4:0]  rs2, // for future use (required in forwarding)
   input wire [31:0] rs2_v,
   input wire [31:0] imm,

   output reg [31:0] result,
  
   output reg        mem_write_enabled,
   output reg        mem_read_enabled,
   output reg [31:0] mem_target,
  
   output reg        reg_write_enabled,
   output reg [4:0]  reg_write_dest,

   output reg        is_jump_enabled,
   output reg [31:0] jump_dest);   

   wire [31:0]       alu_result;
   reg reg_write_enabled_delayed;
   
   alu _alu(.clk(clk),
            .rstn(rstn),
            .instr(instr),
            .rs1_v(rs1_v), .rs2_v(rs2_v),
            .imm(imm),
            .result(alu_result));   
   
   always @(posedge clk) begin
      if (state == EXEC) begin
         // memory        
         mem_write_enabled <= (instr.lb
                               || instr.lh
                               || instr.lw);
         mem_read_enabled <= (instr.sb
                              || instr.sh
                              || instr.sw);         
         mem_target <= alu_result;   

         // reg
         reg_write_enabled_delayed <= !(instr.beq);
         reg_write_dest <= rd;
         
         // control
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
         result <= instr.jal? pc + 4:
                    instr.auipc? pc + imm:
                   alu_result;         
      end else begin
         mem_write_enabled <= 0;
         reg_write_enabled_delayed <= 0;
         is_jump_enabled <= 0;         
      end
      
      reg_write_enabled <= reg_write_enabled_delayed;
   end  
endmodule // execute
