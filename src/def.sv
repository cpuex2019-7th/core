`ifndef _parameters_state_
 `define _parameters_state_

typedef struct {  
   reg [31:0]  rs1;  
   reg [31:0]  rs2;
} regvpair;

typedef struct {
   /////////
   // decoded metadata
   /////////   
   reg [4:0]   rd;
   reg [4:0]   rs1;
   reg [4:0]   rs2;
   reg [31:0]  imm;
   reg [31:0]  pc;
   
   /////////
   // rv32i
   /////////   
   // lui, auipc
   reg         lui;   
   reg         auipc;
   // jumps
   reg         jal;   
   reg         jalr;
   // conditional breaks
   reg         beq;   
   reg         bne;   
   reg         blt;   
   reg         bge;   
   reg         bltu;   
   reg         bgeu;
   // memory control
   reg         lw;
   reg         lbu;
   reg         sb;
   reg         sw;
   // arith immediate
   reg         addi;
   reg         slti;
   reg         sltiu;
   reg         xori;
   reg         ori;
   reg         andi;
   reg         slli;
   reg         srli;
   reg         srai;
   // arith other
   reg         add;
   reg         sub;
   reg         sll;
   reg         slt;
   reg         sltu;
   reg         i_xor;
   reg         srl;
   reg         sra;
   reg         i_or;   
   reg         i_and;
   // TODO: there are some more rv32i instructions required for OS
   
   /////////   
   // rv32m
   /////////
   reg         mul;
   reg         mulh;
   reg         mulhsu;
   reg         mulhu;
   reg         div;
   reg         divu;
   reg         rem;
   reg         remu;

   /////////   
   // rv32f
   /////////
   reg         flw;
   reg         fsw;
   reg         fadd;
   reg         fsub;
   reg         fmul;
   reg         fdiv;
   reg         fsqrt;
   reg         fsgnj;
   reg         fsgnjn;
   reg         fsgnjx;
   reg         fcvtws;
   reg         fmvxw;
   reg         feq;
   reg         fle;
   reg         fcvtsw;
   reg         fmvwx;
   
   /////////   
   // rv32a
   /////////
   // TODO
   
   /////////   
   // rv32c
   /////////
   // TODO
   
   /////////   
   // control flags
   /////////
   reg         rv32f;      
   reg         writes_to_freg_as_rv32f;   
   reg         writes_to_reg_as_rv32f;
   reg         writes_to_reg; // writes_to_reg_as_rv32f + rv32im instrs
   reg         uses_freg_as_rv32f;
   reg         uses_reg_as_rv32f;
   reg         uses_reg; // uses_reg_as_rv32f + rv32im instrs
   
   reg         is_store;   
   reg         is_load;   
   reg         is_conditional_jump;

   reg         is_jump_predicted;
} instructions;
`endif
