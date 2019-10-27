`ifndef _parameters_state_
 `define _parameters_state_
parameter FETCH = 0;
parameter DECODE = 1;
parameter EXEC = 2;
parameter MEM = 3;
parameter WRITE = 4;
parameter INVALID = 5;

typedef struct {  
   reg [31:0]  rs1;  
   reg [31:0]  rs2;
} regvpair;

typedef struct {
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
   reg         lb;
   reg         lh;
   reg         lw;
   reg         lbu;
   reg         lhu;
   reg         sb;
   reg         sh;
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
   wire        writes_to_freg_as_rv32f = (fsw
                                          || flw
                                          || fadd 
                                          || fsub
                                          || fmul
                                          || fdiv
                                          || fsqrt
                                          || fsgnj
                                          || fsgnjn
                                          || fsgnjx
                                          || fcvtsw
                                          || fmvwx);
   
   wire        writes_to_reg_as_rv32f =  (feq
                                          || fle
                                          || fcvtsw
                                          || fmvxw);                              
   wire        rv32f = (fsw
                        || flw
                        || fadd 
                        || fsub
                        || fmul
                        || fdiv
                        || fsqrt
                        || fsgnj
                        || fsgnjn
                        || fsgnjx
                        || fcvtsw
                        || fmvwx
                        || feq
                        || fle
                        || fcvtsw
                        || fmvxw);                              
   
   wire        is_store = (sb
                           || sh
                           || sw
                           || fsw);
   
   wire        is_load =   (lb
                            || lh
                            || lw
                            || lbu
                            || lhu
                            || flw);   
   
   wire        is_conditional_jump =  (beq 
                                       || bne 
                                       || blt 
                                       || bge 
                                       || bltu 
                                       || bgeu);

   wire        writes_to_reg = !(is_conditional_jump
                                 || is_store
                                 || writes_to_freg_as_rv32f);   
} instructions;
`endif
