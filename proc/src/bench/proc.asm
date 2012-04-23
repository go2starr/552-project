//      Basic pipeline tests
        lbi     r0, 0x0
        lbi     r1, 0x1
        lbi     r2, 0x2
        lbi     r3, 0x3
        lbi     r4, 0x4
        add     r4, 0x5
        sub     r4, 0x1
        and     r2, 0x4
        slbi    r2, 0x7
        lbi     r0, 0x0
        subi    r0, r0, 0x8
        bltz    r0, .label1      
        nop
        nop
        nop
        nop

        .label1
        add r0, r2, r0
        sub r1, r0, r0
        bnez r1, .label1


        halt 
        
        
        
