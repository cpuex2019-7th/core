`ifndef _parameters_state_
`define _parameters_state_
parameter FETCH = 0;
parameter DECODE = 1;
parameter EXEC = 2;
parameter MEM = 3;
parameter WRITE = 4;
parameter INVALID = 5;

typedef struct {
   /////////
   // rv32i
   /////////   
   // lui, auipc
   reg lui;   
   reg auipc;
   // jumps
   reg jal;   
   reg jalr;
   // conditional breaks
   reg beq;   
   reg bne;   
   reg blt;   
   reg bge;   
   reg bltu;   
   reg bgeu;
   // memory control
   reg lb;
   reg lh;
   reg lw;
   reg lbu;
   reg lhu;
   reg sb;
   reg sh;
   reg sw;
   // arith immediate
   reg addi;
   reg slti;
   reg sltiu;
   reg xori;
   reg ori;
   reg andi;
   reg slli;
   reg srli;
   reg srai;
   // arith other
   reg add;
   reg sub;
   reg sll;
   reg slt;
   reg sltu;
   reg i_xor;
   reg srl;
   reg sra;
   reg i_or;   
   reg i_and;
   // TODO: there are some more rv32i instructions required for OS
   
   /////////   
   // rv32m
   /////////
   reg mul;
   reg mulh;
   reg mulhsu;
   reg mulhu;
   reg div;
   reg divu;
   reg rem;
   reg remu;

   /////////   
   // rv32a
   /////////
   // TODO
   
   /////////   
   // rv32c
   /////////
   // TODO
} instructions;
`endif
