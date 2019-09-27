`ifndef _parameters_state_
`define _parameters_state_
parameter FETCH = 0;
parameter DECODE = 1;
parameter EXEC = 2;
parameter WRITE = 3;

typedef struct {
   reg addi;   
   reg add;
   reg beq;
   reg jal;
} instructions;
`endif