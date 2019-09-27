`define FETCH 0
`define DECODE 1
`define EXEC 2
`define WRITE 3

typedef struct packed {
   reg addi;   
   reg add;
   reg beq;
   reg jal;
} instructions;
