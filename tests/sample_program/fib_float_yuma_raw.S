min_caml_start:
	fmvwx	f0, x0
	li	x10, 1092616192
	fmvwx	f1, x10
	sw	x1, x2, 4 ; nontail call directly starts
	addi	x2, x2, 8
	jal	x1, fib.10
	addi	x2, x2, -8
	lw	x1, x2, 4
	sw	x1, x2, 4 ; nontail call directly starts
	addi	x2, x2, 8
	jal	x1, min_caml_print_float
	addi	x2, x2, -8
	lw	x1, x2, 4
	jalr	x0, x1, 0
fib.10:
	li	x10, 1065353216
	fmvwx	f2, x10
	fle	x10, f1, f2
	bne	x10, x0, be_else.29 ; tail if
	li	x10, 1065353216
	fmvwx	f2, x10
	fsub	f2, f1, f2 ; fsub
	fsw	f1, x2,  0 ; nontail, save
	fadd	f1, f0, f2 ; args
	sw	x1, x2, 4 ; nontail call directly starts
	addi	x2, x2, 8
	jal	x1, fib.10
	addi	x2, x2, -8
	lw	x1, x2, 4
	li	x10, 1073741824
	fmvwx	f2, x10
	flw	f3, x2, 0
	fsub	f2, f3, f2 ; fsub
	fsw	f1, x2,  4 ; nontail, save
	fadd	f1, f0, f2 ; args
	sw	x1, x2, 12 ; nontail call directly starts
	addi	x2, x2, 16
	jal	x1, fib.10
	addi	x2, x2, -16
	lw	x1, x2, 12
	flw	f2, x2, 4
	fadd	f1, f2, f1 ; fadd
	jalr	x0, x1, 0 ;tail int return
be_else.29:
	jalr	x0, x1, 0 ;tail int return
