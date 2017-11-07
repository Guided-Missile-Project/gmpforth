@ ARM A32 model machine definitions
@
@ parameter stack pushes down
@ return stack pushes down
@
@| Name | Sym | Function                     | Callee | C |  Linux | GMP   |
@|      |     |                              | Saved? |   |        | Forth |
@|------+-----+------------------------------+--------+---+--------+-------|
@| R0   | a1  | C arg1 ret1                  |        | y |      1 | A/P2  |
@| R1   | a2  | arg2 ret2                    |        | y |      2 | B/P3  |
@| R2   | a3  | arg3                         |        | y |      3 | T1    |
@| R3   | a4  | arg4                         |        | y |      4 | T2    |
@| R4   | v1  |                              | y      |   |      5 | T3    |
@| R5   | v2  |                              | y      |   |      6 | T4    |
@| R6   | v3  |                              | y      |   |      7 | T/P1  |
@| R7   | v4  |                              | y      |   | callno |       |
@| R8   | v5  |                              | y      |   |        | IP    |
@| R9   | v6  | Platform register            | ?      |   |        | FP    |
@| R10  | v7  | Variable 7                   | y      |   |        | RP    |
@| R11  | v8  | Variable 8                   |        |   |        | U     |
@| R12  | IP  | Intra-procedure call scratch |        |   |        | W     |
@| R13  | SP  | Stack pointer                | y      |   |        | SP    |
@| R14  | LR  | Link Register                |        |   |        | -     |
@| R15  | PC  | Program counter              |        |   |        | -     |
@| D0   | PC  | FPU                          |        |   |        | F     |

@ Forth Machine Registers

@ registers referenced from GAS common code

        .syntax unified


pp1     .req r6         @ p1 is already an ARM register, so is pp1 here
pp2     .req r0         @ similarly
pp3     .req r1         @ similarly
w       .req r12
rp      .req r10

@ registers referenced from ARM specific code
@ note that 'ip' has a different meaning in ARM assembly than here
@ so the Forth machine IP is called ipp; similarly for fp->fpp

t1      .req r2
t2      .req r3
t3      .req r4
t4      .req r5
ipp     .req r8
fpp     .req r9
spp     .req r13        @ a64 can't use sp, so everyone else has to suffer
u       .req r11

        /* Set IP to the start of the DOES> list */
        .macro $DOES_TARGET
        $SET    ipp, lr
        .endm
