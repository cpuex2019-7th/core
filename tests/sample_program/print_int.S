min_caml_start:
    fmvwx    f0, x0
    addi    x10, x0, -10
    sw    x1, x2, 4         ; nontail call directly starts
    addi    x2, x2, 8
    jal    x1, min_caml_print_int
    addi    x2, x2, -8
    lw    x1, x2, 4
    jalr    x0, x1, 0

;;; ; UART Write
write:
    sw x5, sp, 0
    sw x6, sp, 4
    sw x7, sp, 8
    sw x8, sp, 12
    li x5, 0x7F000000       ; base addr of uart
    lbu x6, x5, 8       ; read control reg
    andi x6, x6, 8  ; get only "Tx FIFO Full"
    addi x7, x0, 8
    beq x6, x7, write       ; if tx fifo is full, we have to wait.
write_actual:
    sb a0, x5, 4            ; write lower 8 bits of arg(a0) to tx fifo
    lw x8, sp, 12
    lw x7, sp, 8
    lw x6, sp, 4
    lw x5, sp, 0
    jalr x0, x1, 0          ; return to caller

;;; ; UART Read
read:
    sw x5, sp, 0
    sw x6, sp, 4
    sw x7, sp, 8
    li x5, 0x7F000000       ; base addr of uart
    lbu x6, x5, 8       ; read control reg
    andi x6, x6, 1  ; get only "Rx FIFO Valid Data"
    addi x7, x0, 1
    beq x6, x7, read_actual
    j read                  ; if no data in uart rx fifo, we have to wait.
read_actual:
    lbu a0, x5, 0           ; read from rx fifo
    lw x7, sp, 8
    lw x6, sp, 4
    lw x5, sp, 0
    jalr x0, x1, 0          ; return to caller

;;; ; min_caml_print_int
    min_caml_print_int_intl.21:
    addi    x6, x0, 0
    bne    x10, x6, be_else.44 ; tail if
    addi    x10, x0, 0
    bne    x5, x10, be_else.45 ; tail if
    jalr    x0, x1, 0      ;tail unit
    be_else.45:
    addi    x10, x0, 45
    jal    x0, write        ; tail call directly routine
    be_else.44:
    addi x11, x0, 10
    div    x6, x10, x11
    sw    x10, x2, 0        ; nontail,save
    add    x10, x6, x0  ; args
    sw    x1, x2, 4 ; nontail call directly starts
    addi    x2, x2, 8
    jal    x1, min_caml_print_int_intl.21
    addi    x2, x2, -8
    lw    x1, x2, 4
    lw    x10, x2, 0        ;nontail restore
    addi x11, x0, 10
    rem    x10, x10, x11
    addi    x10, x10, 48
    jal    x0, write        ; tail call directly routine
min_caml_print_int:
    addi    x5, x0, 0
    bne    x10, x5, be_else.47 ; tail if
    addi    x10, x0, 48
    jal    x0, write        ; tail call directly routine
    be_else.47:
    addi    x5, x0, 0
    blt    x10, x5, bge_else.48 ; nontail if
    addi    x5, x0, 0
    jal    x0, bge_cont.49  ; then sentence ends
    bge_else.48:
    addi    x5, x0, 1
    bge_cont.49:
    addi    x6, x0, 0
    blt    x10, x6, bge_else.50 ; nontail if
    jal    x0, bge_cont.51  ; then sentence ends
    bge_else.50:
    sub    x10, x0, x10
    bge_cont.51:
    jal    x0, min_caml_print_int_intl.21 ; tail call directly routine

min_caml_print_float:
    fmvxw a0, f1
    jalr x0, x1, 0 
