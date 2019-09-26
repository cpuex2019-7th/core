`default_nettype none

typedef struct packed {
   wire addi;   
   wire add;
   wire beq;
   wire jal;
} instructions;

module decoder
  (input wire         clk,
   input wire         rstn,
   input wire [31:0]  instr_raw,
  
   output wire [4:0]  rd,
   output wire [4:0]  rs1,
   output wire [4:0]  rs2,
   output wire [31:0] imm,
   
   input              instructions instr
   );

   // basic component
   // the location of immediate value may change
   wire [6:0]         funct7 = instr_raw[31:25];
   wire [4:0]         _rs2 = instr_raw[24:20];
   wire [4:0]         _rs1 = instr_raw[19:15];
   wire [2:0]         funct3 = instr_raw[14:12];
   wire [4:0]         _rd = instr_raw[11:7];
   wire [6:0]         opcode = instr_raw[6:0];
   
   // r, i, s, b, u, j
   wire               r_type = 1'b1; // TODO
   wire               i_type = 1'b1; // TODO
   wire               s_type = 1'b1; // TODO
   wire               b_type = 1'b1; // TODO
   wire               u_type = 1'b1; // TODO
   wire               j_type = 1'b1; // TODO
   
   assign instr.beq = (opcode == 7'b1100011) && (funct3 = 3'b000);
   assign instr.jal = (opcode == 7'b1101111);
   assign instr.addi = (opcode == 7'b0010011);
   assign instr.add = (opcode == 7'b011011) && (funct3 == 3'b000) && (funct7 == 3'b0000000);

   assign rd = (r_type || i_type || u+type || j_type) ? rd : 5'b00000;
   assign rs1 = (r_type || i_type || s_type || b_type) ? rs1 : 5'b00000;
   assign rs2 = (r_type || s_type || b_type) ? rs2 : 5'b00000;

   // NOTE: this sign extention may have bugs; oops...
   assign imm = i_type ? (instr_raw[31] 
                          ? {~20'b0, instr_raw[31:20]}
                          : {20'b0, instr_raw[31:20]})
     : s_type ? (instr_raw[31] 
                 ? {~20'b0, instr_raw[31:25], instr_raw[11:7]}
                 : {20'b0, instr_raw[31:25], instr_raw[11:7]})
       : b_type ? (instr_raw[31] 
                   ? {~19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8]}
                   : {19'b0, instr_raw[31], instr_raw[7], instr_raw[30:25], instr_raw[11:8]})
         : u_type ? {instr_raw[31:12], 11'b0}
                : j_type ? (instr_raw[31]
                            ? {~11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21]}
                            : {~11'b0, instr_raw[31], instr_raw[19:12], instr_raw[20], instr_raw[30:21]})
                  : 31'b0;     
endmodule

