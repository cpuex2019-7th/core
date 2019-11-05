main:
    jal ra, read                 ; function call
    jal ra, write                ; function call
    j main
    
write:
    li t0, 0x7F000000           ; base addr of uart
    lbu t1, t0, 8                ; read control reg
    andi t1, t1, 8              ; get only "Tx FIFO Full"
    addi t2, zero, 8
    beq t1, t2, write           ; if tx fifo is full, we have to wait.
write_actual:
    sb a0, t0, 4                ; write lower 8 bits of arg(a0) to tx fifo
    jalr zero, ra, 0            ; return to caller
    
    
read:
    li t0, 0x7F000000           ; base addr of uart
    lbu t1, t0, 8                ; read control reg
    andi t1, t1, 1              ; get only "Rx FIFO Valid Data"
    addi t2, zero, 1
    beq t1, t2, read_actual
    j read                      ; if no data in uart rx fifo, we have to wait.
read_actual:        
    lbu a0, t0, 0                ; read from rx fifo
    jalr zero, ra, 0            ; return to caller
