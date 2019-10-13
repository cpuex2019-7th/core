    addi t0, zero, 0x41
    li sp, 0

loop:   
    sb t0, sp, 0x4
    lw t1, sp, 0x8    
    j loop
