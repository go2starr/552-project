//   DO NOT CHANGE
        lbi     r0, 0x10
        lbi     r1, 0x01

//   TEST ALU @ 1c5b76
        add     r2, r0, r1

//   TEST ALU @ 1fb5355
        lbi     r0, 0x01
        lbi     r1, 0x02

        sub     r2, r0, r1   // SUB
        
