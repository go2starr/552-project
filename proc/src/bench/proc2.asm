      lbi   r4, 0x0
      lbi   r3, 0x1
      lb1   r2, 0x2
      lbi   r1, 0x3
      lb1   r0, 0x4
      add   r5, r0, r1
      sub   r6, r2, r3
      beqz  r6, .label1
      bnez  r6, .label2


      .label1
      st    r6, r4, 0x0
      st    r5, r3, 0x0
      ld    r5, r4, 0x0   


      .label2
      lbi   r2, 0x08
      jal   .jroutine
      add   r2, r2, r6
      st    r6, r2, 0
      halt
      halt
      halt
      halt
      halt


      .jroutine
      sub r2, r2, 0x1
      bnez r2, .jroutine
      ret  
