module predictor(
                 input [31:0]  instr_raw,
                 input [31:0]  current_pc,

                 output        is_jump_predicted,
                 output [31:0] next_pc);
   
   wire [6:0]                  opcode = instr_raw[6:0];
   wire [2:0]                  funct3 = instr_raw[14:12];   
   wire                        b_type = (opcode == 7'b1100011); 
   wire                        j_type = (opcode == 7'b1101111); 
   
   wire                        _jal = (opcode == 7'b1101111);   
   wire                        _beq = (opcode == 7'b1100011) && (funct3 == 3'b000);
   wire                        _bne =  (opcode == 7'b1100011) && (funct3 == 3'b001);
   wire                        _blt =  (opcode == 7'b1100011) && (funct3 == 3'b100);
   wire                        _bge = (opcode == 7'b1100011) && (funct3 == 3'b101);
   wire                        _bltu = (opcode == 7'b1100011) && (funct3 == 3'b110);
   wire                        _bgeu =  (opcode == 7'b1100011) && (funct3 == 3'b111);
   wire [31:0]                 imm = b_type? (instr_raw[31] ? {~19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8], 1'b0}:
                                              {19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8], 1'b0}):
                               j_type ? (instr_raw[31] ? {~11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21], 1'b0}:
                                         {11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21], 1'b0}):
                               32'b0;

   assign is_jump_predicted = (b_type | j_type)? 1'b1:
                              1'b0;
   
   assign next_pc = (b_type | j_type)? current_pc + imm:
                    current_pc + 4;   
endmodule
