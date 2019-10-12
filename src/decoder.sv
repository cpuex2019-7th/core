`include "def.sv"

module decoder
  (input wire         clk,
   input wire        rstn,
   input wire [2:0]  state,
   input wire [31:0] instr_raw,
  
   output            instructions instr,

   output reg [4:0]  rd,
   output wire [4:0] rs1,
   output wire [4:0] rs2,
   output reg [31:0] imm);

   // basic component
   // the location of immediate value may change
   wire [6:0]        funct7 = instr_raw[31:25];
   wire [4:0]        _rs2 = instr_raw[24:20];
   wire [4:0]        _rs1 = instr_raw[19:15];
   wire [2:0]        funct3 = instr_raw[14:12];
   wire [4:0]        _rd = instr_raw[11:7];
   wire [6:0]        opcode = instr_raw[6:0];
   
   // r, i, s, b, u, j
   // TODO: check here when you add new instructions
   // TODO!!!!!!!!!!!!!!!!!!!
   wire              r_type = (opcode == 7'b0110011); 
   wire              i_type = (opcode == 7'b1100111 | opcode == 7'b0000011 | opcode == 7'b0010011); 
   wire              s_type = (opcode == 7'b0100011); 
   wire              b_type = (opcode == 7'b1100011); 
   wire              u_type = (opcode == 7'b0110111 | opcode == 7'b0010111);   
   wire              j_type = (opcode == 7'b1101111); 

   assign rs1 = (r_type || i_type || s_type || b_type) ? _rs1 : 5'b00000;
   assign rs2 = (r_type || s_type || b_type) ? _rs2 : 5'b00000;
   
   always @(posedge clk) begin
      if (rstn && state ==  DECODE) begin
         /////////   
         // rv32i
         /////////   
         // lui, auipc
         instr.lui <= (opcode == 7'b0110111);
         instr.auipc <= (opcode == 7'b0010111);         
         // jumps
         instr.jal <= (opcode == 7'b1101111);         
         instr.jalr <= (opcode == 7'b1100111);         
         // conditional breaks
         instr.beq <= (opcode == 7'b1100011) && (funct3 == 3'b000);         
         instr.bne <= (opcode == 7'b1100011) && (funct3 == 3'b001);         
         instr.blt <= (opcode == 7'b1100011) && (funct3 == 3'b100);         
         instr.bge <= (opcode == 7'b1100011) && (funct3 == 3'b101);         
         instr.bltu <= (opcode == 7'b1100011) && (funct3 == 3'b110);         
         instr.bgeu <= (opcode == 7'b1100011) && (funct3 == 3'b111);         
         // memory control
         instr.lb = (opcode == 7'b0000011) && (funct3 == 3'b000);         
         instr.lh = (opcode == 7'b0000011) && (funct3 == 3'b001);         
         instr.lw = (opcode == 7'b0000011) && (funct3 == 3'b010);         
         instr.lbu = (opcode == 7'b0000011) && (funct3 == 3'b100);         
         instr.lhu = (opcode == 7'b0000011) && (funct3 == 3'b101);         
         instr.sb = (opcode == 7'b0100011) && (funct3 == 3'b000);         
         instr.sh = (opcode == 7'b0100011) && (funct3 == 3'b001);         
         instr.sw = (opcode == 7'b0100011) && (funct3 == 3'b010);         

         // arith imm
         instr.addi <= (opcode == 7'b0010011) && (funct3 == 3'b000);
         instr.slti <= (opcode == 7'b0010011) && (funct3 == 3'b010);
         instr.sltiu <= (opcode == 7'b0010011) && (funct3 == 3'b011);
         instr.xori <= (opcode == 7'b0010011) && (funct3 == 3'b100);
         instr.ori <= (opcode == 7'b0010011) && (funct3 == 3'b110);
         instr.andi <= (opcode == 7'b0010011) && (funct3 == 3'b111);
         instr.slli <= (opcode == 7'b0010011) && (funct3 == 3'b001);
         instr.srli <= (opcode == 7'b0010011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
         instr.srai <= (opcode == 7'b0010011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);

         // arith others
         instr.add <= (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
         instr.sub <= (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
         instr.sll <= (opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
         instr.slt <= (opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000000);
         instr.sltu <= (opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000000);
         instr.i_xor <= (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000000);
         instr.srl <= (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
         instr.sra <= (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
         instr.i_or <= (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000000);
         instr.i_and <= (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000000);

         /////////   
         // rv32m
         /////////
         instr.mul <= (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000001);
         instr.mulh <= (opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000001);
         instr.mulhsu <= (opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000001);
         instr.mulhu <= (opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000001);
         instr.div <= (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000001);
         instr.divu <= (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000001);
         instr.rem <= (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000001);
         instr.remu <= (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000001);

         /////////   
         // rv32a
         /////////
         // TODO

         /////////   
         // rv32c
         /////////
         // TODO

         rd <= (r_type || i_type || u_type || j_type) ? _rd : 5'b00000;

         // NOTE: this sign extention may have bugs; oops...
         imm <= i_type ? (instr_raw[31] ? {~20'b0, instr_raw[31:20]}:
                          {20'b0, instr_raw[31:20]}):
                s_type ? (instr_raw[31] ? {~20'b0, instr_raw[31:25], instr_raw[11:7]}:
                          {20'b0, instr_raw[31:25], instr_raw[11:7]}):
                b_type ? (instr_raw[31] ? {~19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8], 1'b0}:
                          {19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8], 1'b0}):
                u_type ? {instr_raw[31:12], 12'b0} : 
                j_type ? (instr_raw[31] ? {~11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21], 1'b0}:
                          {11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21], 1'b0}):
                32'b0;
      end
   end
endmodule
