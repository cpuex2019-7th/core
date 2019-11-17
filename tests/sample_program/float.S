main:
    li a0, 1084227584
    fmvwx ft1, a0               ; 5.0

    li a0, 1082130432
    fmvwx ft2, a0               ; 4.0

    fdiv ft3, ft1, ft2          ; 1.25
    fsqrt ft4, ft2              ; 2.0

    fadd ft5, ft1, ft2          ; 9.0

    
