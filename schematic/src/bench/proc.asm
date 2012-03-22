//   DO NOT CHANGE
        lbi     r0, 0x10
        lbi     r1, 0x01

//   TEST ALU @ 1c5b76
        add     r2, r0, r1

//   TEST ALU @ 1fb5355
        lbi     r0, 0x01
        lbi     r1, 0x02

        sub     r2, r0, r1   // SUB
        ror     r2, r1, r0   // ROR

        or      r2, r0, r1   // OR
        and     r2, r0, r1,  // AND
        rol     r2, r0, r1   // ROL
        sll     r2, r0, r1   // SLL
        sra     r2, r0, r1   // SRA
        seq     r2, r0, r1   // SEQ
        slt     r2, r0, r1   // SLT
        sle     r2, r0, r1   // SLE
        
        
//   TEST ALU IMMEDIATES @ 29b81b
        addi    r2, r0, 0x09
        subi    r2, r0, 0x01
        ori     r2, r0, 0x10

//   TEST SLBI
        slbi    r1, 0xb

//   TEST STU
        lbi     r1, 2
        stu     r2, r1, 2

//   TEST JAL
        jal     2
        nop
        addi    r2, r0, 0
