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
   output reg [31:0] mem_write_dest,
   
   output reg        reg_write_enabled,
   output reg [4:0]  reg_write_dest,

   output reg        is_jump_enabled,
   output reg [31:0] jump_dest);   

   wire [31:0]       alu_result;
   
   alu _alu(.clk(clk),
            .rstn(rstn),
            .instr(instr),
            .rs1_v(rs1_v), .rs2_v(rs2_v),
            .imm(imm),
            .result(alu_result));   
     
   always @(posedge clk) begin
      if (state == EXEC) begin
         // memory        
         mem_write_enabled <= 0; // TODO  (theres no memory instruction)
         mem_write_dest <= 0; // TODO          

         // reg
         reg_write_enabled <= !(instr.beq);
         reg_write_dest <= rd;         
         
         // control
         is_jump_enabled <= ((instr.jal) || ((instr.beq) &&  (alu_result == 32'd1)));
         jump_dest <= pc + imm;

         // what to write
         result <= (instr.jal)? pc + 4:
                   alu_result;         
      end else begin
         mem_write_enabled <= 0;
         reg_write_enabled <= 0;
         is_jump_enabled <= 0;         
      end
   end  
endmodule // execute