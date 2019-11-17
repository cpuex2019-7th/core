    li ra, 0x12345678
    sw ra, sp, 20
    addi ra, zero, 0
    li t1, 0x3f800000
    fmvwx ft1, t1
    addi zero, zero, 0
    addi zero, zero, 0
    addi zero, zero, 0
    addi zero, zero, 0
    addi zero, zero, 0
    addi zero, zero, 0    
    lw ra, sp, 20
    fsw ft1, sp, 20
    sw ra, sp, 24
