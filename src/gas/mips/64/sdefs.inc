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
| R8   | a4   |          |        |   |      5 |       |
| R9   | a5   |          |        |   |      6 |       |
| R10  | a6   |          |        |   |        |       |
| R11  | a7   |          |        |   |        |       |
| R12  | t0   |          |        |   |        | t0    |
| R13  | t1   |          |        |   |        | t1    |
| R14  | t2   |          |        |   |        | t2    |
| R15  | t3   |          |        |   |        | t3    |
| R16  | s0   |          |        |   |        | pp1   |
| R17  | s1   |          |        |   |        | pp2   |
| R18  | s2   |          |        |   |        | pp3   |
| R19  | s3   |          |        |   |        | W     |
| R20  | s4   |          |        |   |        | IPP   |
| R21  | s5   |          |        |   |        | RP    |
| R22  | s6   |          |        |   |        | U     |
| R23  | s7   |          |        |   |        | t4    |
| R24  | t8   |          |        |   |        | t8    |
| R25  | t9   |          |        |   |        | t9    |
| R26  | k0   |          |        |   |        |       |
| R27  | k1   |          |        |   |        |       |
| R28  | gp   |          |        |   |        | _pool |
| R29  | sp   |          |        |   |        | SP    |
| R30  | s8   |          |        |   |        | FP    |
| R31  | ra   |          |        |   |        |       |
*/


        /* Abstract register names */
        .set pp1, $s0
        .set pp2, $s1
        .set pp3, $s2
        .set w,   $s3
        .set ipp, $s4
        .set rp,  $s5
        .set fpp, $s8
        .set u,   $s6
        .set spp, $sp
        .set t0,  $t0
        .set t1,  $t1
        .set t2,  $t2
        .set t3,  $t3
        .set t4,  $s7
        .set t8,  $t8 /* um/mod */
        .set t9,  $t9 /* um/mod */

        /* Store a 64 bit word in 'e' to address entity 'x' */
        .macro $XST e x
        sd      \e, \x
        .endm

        /* Load a 64 bit word in 'e' from address entity 'x' */
        .macro $XLD e x
        ld      \e, \x
        .endm

        /* Load a 64 bit address 'x' in 'e' */
        .macro $LA e x
        dla     \e, \x
        .endm

        /* Add */
        .macro $ADD a b c
        .ifb \c
        daddu     \a, \a, \b
        .else
        daddu     \a, \b, \c
        .endif
        .endm

        /* Add Immediate */
        .macro $ADDI a b k
        daddiu    \a, \b, \k
        .endm

        /* Subtract */
        .macro $SUB a b c
        .ifb \c
        dsubu     \a, \a, \b
        .else
        dsubu     \a, \b, \c
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
        $XOP   dsll, \a, \b, \c
        .endm

        /* Shift right logical */
        .macro $SHR a b c
        $XOP   dsrl, \a, \b, \c
        .endm

        /* Shift right arithmetic */
        .macro $SAR a b c
        $XOP   dsra, \a, \b, \c
        .endm

        /* Signed Multiplication */
        .macro $MULS a b c
        dmul      \a, \b, \c
        .endm

        /* Unsigned Multiplication */
        .macro $MULU a b
        dmultu   \a, \b
        .endm
