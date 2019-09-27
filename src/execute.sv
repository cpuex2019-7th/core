module execute
  (input wire clk,
   input wire        rstn,
   input wire [2:0] state,

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

   always @(posedge clk) begin
      if (state == EXEC) begin
         if(instr.addi) begin
            is_jump_enabled <= 0;
            mem_write_enabled <= 0;
            reg_write_enabled <= 1;
            reg_write_dest <= rd;
            result <= $signed(rs1_v) + $signed(imm);
         end else if(instr.add) begin
            is_jump_enabled <= 0;      
            mem_write_enabled <= 0;
            reg_write_enabled <= 1;
            reg_write_dest <= rd;
            result <= $signed(rs1_v) + $signed(rs2_v);
         end else if(instr.beq) begin
            mem_write_enabled <= 0;
            reg_write_enabled <= 0;
            if (rs1_v == rs2_v) begin
               is_jump_enabled <= 1; 
               jump_dest <= pc + imm;          
            end else begin
               is_jump_enabled <= 0;            
            end
         end else if(instr.jal) begin
            mem_write_enabled <= 0;
            reg_write_enabled <= 1;
            reg_write_dest <= rd;         
            result <= pc + 4;

            is_jump_enabled <= 1;
            jump_dest <= pc + imm;         
         end else begin
            mem_write_enabled <= 0;
            reg_write_enabled <= 0;
            result <= 0;
         end 
      end else begin
         mem_write_enabled <= 0;
         reg_write_enabled <= 0;
         result <= 0;         
      end
   end  
endmodule // execute
