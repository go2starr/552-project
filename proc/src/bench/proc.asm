//      Basic pipeline tests
        lbi     r0, 0x0 // r0 <- 0
        lbi     r1, 0x1 // r1 <- 1
        lbi     r2, 0x2 // r2 <- 2
        lbi     r3, 0x3 // r3 <- 3
        lbi     r4, 0x4 // r4 <- 4
        add     r4, 0x5 // r4 <- r4 + 5 == 9 && should stall
        sub     r4, 0x1 // r4 <- r4 - 1 == 8 && should stall
        and     r2, 0x4 // r2 <- r2 && 4 == 0
        slbi    r2, 0x7 // r2 <- r2 << 8 | 7 == 7  && should stall
        lbi     r0, 0x0 // r0 <- 0  
        subi    r0, r0, 0x8  // r0 <-r0 - 8 == -8 && should stall
        bltz    r0, .label1  // should jump to label1  && should stall  
        nop
        nop
        nop
        nop

        .label1
        add r0, r2, r0     // ro <- r0 + r2 == -1 
        sub r1, r0, r0     // r1 <- r0 - r0 == 0 && should stall
        bnez r1, .label1   // equal to zero, so shouldn't branch; halt


        halt 
        
        
        
