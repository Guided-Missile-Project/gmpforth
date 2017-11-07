/*
  ARM A64 model machine definitions

 parameter stack pushes down
 return stack pushes down

| Name | Sym   | Function | Callee | C |    Linux | GMP   |
|      |       |          | Saved? |   |          | Forth |
|------+-------+----------+--------+---+----------+-------|
| X0   |       |          |        |   |        1 |       |
| X1   |       |          |        |   |        2 |       |
| X2   |       |          |        |   |        3 |       |
| X3   |       |          |        |   |        4 |       |
| X4   |       |          |        |   |        5 |       |
| X5   |       |          |        |   |        6 |       |
| X6   |       |          |        |   |        7 |       |
| X7   |       |          |        |   | callno32 |       |
| X8   |       |          |        |   | callno   |       |
| X9   |       | temp     |        |   |          |       |
| X10  |       | temp     |        |   |          | P2    |
| X11  |       | temp     |        |   |          | P3    |
| X12  |       | temp     |        |   |          | T1    |
| X13  |       | temp     |        |   |          | T2    |
| X14  |       | temp     |        |   |          | T3    |
| X15  |       | temp     |        |   |          | T4    |
| X16  | IP0   |          |        |   |          |       |
| X17  | IP1   |          |        |   |          |       |
| X18  |       | platform |        |   |          |       |
| X19  |       |          | y      |   |          | P1    |
| X20  |       |          | y      |   |          | IP    |
| X21  |       |          | y      |   |          | SP    |
| X22  |       |          | y      |   |          | RP    |
| X23  |       |          | y      |   |          | FP    |
| X24  |       |          | y      |   |          | U     |
| X25  |       |          | y      |   |          | W     |
| X26  |       |          | y      |   | callno64 |       |
| X27  |       |          | y      |   |          |       |
| X28  |       |          | y      |   |          |       |
| X29  | FP    | frame    |        |   |          |       |
| X30  | LR    |          |        |   |          |       |
| SP   | SP/ZR |          |        |   |          |       |
| V0   |       | FPU      |        |   |          |  F    |

By glibc inspection, Linux callno is in x8, but isn't yet evident
in linux kernel inspection.

*/


        .set _A64, 1    /* For common code that needs to know */

/* registers referenced from GAS common code */


pp1     .req x19        /* p1 is already an ARM register, so is pp1 here */
pp2     .req x10        /* similarly */
pp3     .req x11        /* similarly */
w       .req x25
rp      .req x22

/* 'word' register versions, needed for $STB macro, um* impl

   Can't store a 64bit register as a byte, and to use the 32 bit register.
   Annoying that the assembler can't figure this out.
*/
pp1w    .req w19
pp2w    .req w10

/*
 registers referenced from ARM specific code
 note that 'ip' has a different meaning in ARM assembly than here
 so the Forth machine IP is called ipp; similarly for fp->fpp
*/

t1      .req x12
t2      .req x13
t3      .req x14
t4      .req x15
ipp     .req x20
fpp     .req x23
spp     .req x21       /* a64 can't use sp, so everyone else has to suffer */
u       .req x24

        /* Set IP to the start of the DOES> list */
        .macro $DOES_TARGET
        $SET    ipp, x30
        .endm
