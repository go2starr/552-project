      lbi   r4, 0x0  // r4 <- 0
      lbi   r3, 0x1  // r3 <- 1
      lb1   r2, 0x2  // r2 <- 2
      lbi   r1, 0x3  // r1 <- 3
      lb1   r0, 0x4  // r0 <- 4
      add   r5, r0, r1 // r5 <- r0 + r1 == 7 && should stall
      sub   r6, r2, r3  // r6 <- r2 + r3 == 3
      beqz  r6, .label1 // r6 == 3, so don't take branch
      bnez  r6, .label2 // r6 == 3, so take branch


      .label1
      st    r6, r4, 0x0
      st    r5, r3, 0x0
      ld    r5, r4, 0x0   


      .label2
      lbi   r2, 0x08    // r2 <- 8
      jal   .jroutine   // jump to routine
      add   r2, r2, r6  // r2 <- r2 + r6 == 3
      st    r6, r2, 0   // addr (r2 + 0) <- r6 ; addr 0 <- 3
      halt  // halt
      halt
      halt
      halt
      halt


      .jroutine
      sub r2, r2, 0x1   // while r2 != 0, r2 <- r2 - 1
      bnez r2, .jroutine   // branch back
      ret  // then return
