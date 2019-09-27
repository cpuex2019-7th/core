module alu 
  (input wire        clk,
   input wire        rstn,
                     
                     instructions instr,

   input wire [31:0] rs1_v,
   input wire [31:0] rs2_v,
   input wire [31:0] imm,

   output reg [31:0] result

   );

   always @(posedge CLK) begin
      result <= instr.addi? rs1_v + imm:
                instr.add? rs1_v + rs2_v:      
                (instr.beq | instr.jal)? rs1_v + imm;      
   end
end
endmodule
