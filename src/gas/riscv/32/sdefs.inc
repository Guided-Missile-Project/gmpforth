/*
| Name | Sym  | Function | Callee | C |  Linux | GMP   |
|      |      |          | Saved? |   |        | Forth |
|------+------+----------+--------+---+--------+-------|
| R0   | zero |          |        |   |        |       |
| R1   | at   |          |        |   |        |       |
| R2   | v0   |          |        |   | callno |       |
| R3   | v1   |          |        |   |        |       |
| R4   | a0   |          |        |   |      1 |       |
| R5   | a1   |          |        |   |      2 |       |
| R6   | a2   |          |        |   |      3 |       |
| R7   | a3   |          |        |   |      4 |       |
| R8   | t0   |          |        |   |      5 |       |
| R9   | t1   |          |        |   |      6 | t1    |
| R10  | t2   |          |        |   |        | t2    |
| R11  | t3   |          |        |   |        | t3    |
| R12  | t4   |          |        |   |        | t4    |
| R13  | t5   |          |        |   |        | pp2   |
| R14  | t6   |          |        |   |        | pp3   |
| R15  | t7   |          |        |   |        | w     |
| R16  | t8   |          |        |   |        | t8    |
| R17  | t9   |          |        |   |        | t9    |
| R18  | s0   |          |        |   |        | IP    |
| R19  | s1   |          |        |   |        | RP    |
| R20  | s2   |          |        |   |        | FP    |
| R21  | s3   |          |        |   |        | U     |
| R22  | s4   |          |        |   |        | pp1   |
| R23  | s5   |          |        |   |        |       |
| R24  | s6   |          |        |   |        |       |
| R25  | s7   |          |        |   |        |       |
| R26  | s8   |          |        |   |        |       |
| R27  | k0   |          |        |   |        |       |
| R28  | k1   |          |        |   |        |       |
| R29  | gp   |          |        |   |        |       |
| R30  | sp   |          |        |   |        | SP    |
| R31  | ra   |          |        |   |        |       |
*/


        /* Abstract register names */
        .set pp2, $t5
        .set pp3, $t6
        .set w,   $t7
        .set ipp, $s0
        .set rp,  $s1
        .set fpp, $s2
        .set u,   $s3
        .set pp1, $s4
        .set spp, $sp
        .set t0,  $t0
        .set t1,  $t1
        .set t2,  $t2
        .set t3,  $t3
        .set t4,  $t4
        .set t8,  $t8 /* um/mod */
        .set t9,  $t9 /* um/mod */

        /* Store a 32 bit word in 'e' to address entity 'x' */
        .macro $XST e x
        sw      \e, \x
        .endm

        /* Load a 32 bit word in 'e' from address entity 'x' */
        .macro $XLD e x
        lw      \e, \x
        .endm

        /* Load a 32 bit address 'x' in 'e' */
        .macro $LA e x
        la      \e, \x
        .endm

        /* Add */
        .macro $ADD a b c
        .ifb \c
        addu      \a, \a, \b
        .else
        addu      \a, \b, \c
        .endif
        .endm

        /* Add Immediate */
        .macro $ADDI a b k
        addiu     \a, \b, \k
        .endm

        /* Subtract */
        .macro $SUB a b c
        .ifb \c
        subu      \a, \a, \b
        .else
        subu      \a, \b, \c
        .endif
        .endm

        .macro $XOP a b c d
        .ifb \d
        .ifb \c
         \a      \b, \b, 1
        .else
         \a      \b, \b, \c
        .endif
        .else
        \a       \b, \c, \d
        .endif
        .endm

        /* Shift left */
        .macro $SHL a b c
        $XOP   sll, \a, \b, \c
        .endm

        /* Shift right logical */
        .macro $SHR a b c
        $XOP   srl, \a, \b, \c
        .endm

        /* Shift right arithmetic */
        .macro $SAR a b c
        $XOP   sra, \a, \b, \c
        .endm

        /* Signed Multiplication */
        .macro $MULS a b c
        mul      \a, \b, \c
        .endm

        /* Unsigned Multiplication */
        .macro $MULU a b
        multu    \a, \b
        .endm
