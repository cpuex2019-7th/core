min_caml_start:
	addi    x4, x0, 3
	sw      x1, x2, 4
	addi    x2, x2, 8
	jal     x1, fib.10
	addi    x2, x2, -8
	lw      x1, x2, 4
	sw      x1, x2, 4
	addi    x2, x2, 8
	jal     x1, min_caml_print_int
	addi    x2, x2, -8
	lw      x1, x2, 4
	j       ret
fib.10:
	addi    x5, x0, 1
	blt     x5, x4, bge_else.24
	jalr    x0, x1, 0
	bge_else.24:
	addi    x5, x4, -1
	sw      x4, x2, 0
	add     x4, x5, x0
	sw      x1, x2, 4
	addi    x2, x2, 8
	jal     x1, fib.10
	addi    x2, x2, -8
	lw      x1, x2, 4
	lw      x5, x2, 0
	addi    x5, x5, -2
	sw      x4, x2, 4
	add     x4, x5, x0
	sw      x1, x2, 12
	addi    x2, x2, 16
	jal     x1, fib.10
	addi    x2, x2, -16
	lw      x1, x2, 12
	lw      x5, x2, 4
	add     x4, x5, x4
	jalr    x0, x1, 0
min_caml_print_int:
    addi    x6, ra, 0
    add     a0, x4, zero        ; arg
    jal     ra, write           ; call write with a0 (x4)
    addi    ra, x6, 0
	jalr    x0, x1, 0
ret:
    addi zero, zero, 1          ; nop
    j ret

write:     
    li a1, 0x7F000000           ; base addr of uart
    lb a2, a1, 8                ; read control reg
    andi a2, a2, 8              ; get only "Tx FIFO Full"
    addi a3, zero, 8
    beq a2, a3, write           ; if tx fifo is full, we have to wait.
write_actual:
    sb a0, a1, 4                ; write lower 8 bits of arg(a0) to tx fifo
    jalr zero, ra, 0            ; return to caller
