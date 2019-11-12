min_caml_start:
    ;;     li  x10, 1106247680         ; 30.0
    ;;     fmvwx   f1, x10             ; f1 = 30.0
    li x10, 1092616192          ; 10.0
    fmvwx f1, x10
    
    sw  ra, sp, 4 
    addi    sp, sp, 8
    jal ra, fib.10
    addi    sp, sp, -8
    lw  ra, sp, 4
    
    sw  ra, sp, 4 
    addi    sp, sp, 8
    jal ra, min_caml_print_float
    addi    sp, sp, -8
    lw  ra, sp, 4
    
    jalr    x0, ra, 0
    
fib.10:
    ;; f2 = 1.0
    li  x10, 1065353216         ; 1.0
    fmvwx   f2, x10             ; f2 = 1.0

    ;; jump if argv[0] <= 1.0
    fle    x10, f1, f2
    bne x10, x0, be_else.29
    
    li  x10, 1065353216         ; 1.0
    fmvwx   f2, x10             ; f2 = 1.0

    fsub   f2, f1, f2           ; f2 = f1 - f2 = argv[0] - 0.1
    
    fsw f1, sp,  0              ; sp[0] = f1 = argv[0]
    fadd   f1, f0, f2           ; f2 = f1

    ;; stack
    ;; sp+0 = f1 = argv[0]
    ;; sp+4 = ra
    sw  ra, sp, 4
    addi    sp, sp, 8
    jal ra, fib.10              ; here we assume f1 = argv[0] is the 1st argument.
    addi    sp, sp, -8
    lw  ra, sp, 4
    
    li  x10, 1073741824         ; 2.0
    fmvwx   f2, x10             ; f2 = 2.0    
    flw f3, sp, 0               ; f3 = sp[0] = argv[0]
    fsub   f2, f3, f2           ; f2 = f3 - f2 = argv[0] - 2.0
    fsw f1, sp,  4              ; sp[1] = f1 = fib.10(argv[0])
    fadd   f1, f0, f2           ; f2 = f1 = fib.10(argv[0])

    ;; stack
    ;; sp+0 = f3 = argv[0]
    ;; sp+4 = f1 = fib(argv[0])
    ;; sp+8 = ??? (there's no assignments)
    ;; sp+12= ra
    sw  ra, sp, 12 
    addi    sp, sp, 16
    jal ra, fib.10              ; here we assume f1 is the return value.
    addi    sp, sp, -16
    lw  ra, sp, 12
    flw f2, sp, 4               ; f2 = f1 = fib(argv[0])
    
    fadd   f1, f2, f1           ; f1 = f2 + f1 = fib(argv[0]) + fib.10(argv[0])
    ;;  return 
    jalr    x0, ra, 0 
be_else.29:
    ;; return argv[0] itself
    jalr    x0, ra, 0
    
main:
        jal ra, read                ; function call
        jal ra, write                ; function call
        j main
write:
        li x5, 0x7F000000           ; base addr of uart
        lb x6, x5, 8                ; read control reg
        andi x6, x6, 8              ; get only "Tx FIFO Full"
        addi x7, x0, 8
        beq x6, x7, write           ; if tx fifo is full, we have to wait.
write_actual:
        sb x10, x5, 4                ; write lower 8 bits of arg(a0) to tx fifo
        jalr x0, ra, 0            ; return to caller
read:
        li x5, 0x7F000000           ; base addr of uart
        lb x6, x5, 8                ; read control reg
        andi x6, x6, 1              ; get only "Rx FIFO Valid Data"
        addi x7, x0, 1
        beq x6, x7, read_actual
        j read                      ; if no data in uart rx fifo, we have to wait.
read_actual:
        lb x10, x5, 0                ; read from rx fifo
        jalr x0, ra, 0            ; return to caller
min_caml_print_int:
        jalr x0, ra, 0
min_caml_print_float:
        fmvxw x10, f1
        jalr x0, ra, 0
