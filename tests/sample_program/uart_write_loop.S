    li t0, 0x44434241    
    li sp, 0x7F000000

loop:   
    sw t0, sp, 0x4
    lw t1, sp, 0x8
    j loop
