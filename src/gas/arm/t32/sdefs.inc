@ ARM T32 model machine definitions
@
@ parameter stack pushes down
@ return stack pushes down
@
@| Name | Sym | Function                     | Callee | C |  Linux | GMP   |
@|      |     |                              | Saved? |   |        | Forth |
@|------+-----+------------------------------+--------+---+--------+-------|
@| R0   | a1  | C arg1 ret1                  |        | y |      1 | P2    |
@| R1   | a2  | arg2 ret2                    |        | y |      2 | W     |
@| R2   | a3  | arg3                         |        | y |      3 | T1    |
@| R3   | a4  | arg4                         |        | y |      4 | T2    |
@| R4   | v1  |                              | y      |   |      5 | RP    |
@| R5   | v2  |                              | y      |   |      6 | IP    |
@| R6   | v3  |                              | y      |   |      7 | T/P1  |
@| R7   | v4  |                              | y      |   | callno | U     |
@| R8   | v5  |                              | y      |   |        | P3    |
@| R9   | v6  | Platform register            | ?      |   |        | FP    |
@| R10  | v7  | Variable 7                   | y      |   |        | T3    |
@| R11  | v8  | Variable 8                   |        |   |        | T4    |
@| R12  | IP  | Intra-procedure call scratch |        |   |        |       |
@| R13  | SP  | Stack pointer                | y      |   |        | SP    |
@| R14  | LR  | Link Register                |        |   |        | -     |
@| R15  | PC  | Program counter              |        |   |        | -     |
@| D0   | PC  | FPU                          |        |   |        | F     |

        .syntax unified

        .arch armv7-m
        .thumb

        .set _THUMB, 1  @ lest there be any doubt

@ Forth Machine Registers
@ Most common registers are in the Thumb register set r0-r7, which are also used
@ for system call parameter passing

@ registers referenced from GAS common code


pp1     .req r6         @ p1 is already an ARM register, so is pp1 here
pp2     .req r0         @ similarly
pp3     .req r8         @ similarly
w       .req r1
rp      .req r4

@ registers referenced from ARM specific code
@ note that 'ip' has a different meaning in ARM assembly than here
@ so the Forth machine IP is called ipp; similarly for fp->fpp

t1      .req r2
t2      .req r3
t3      .req r10
t4      .req r11
ipp     .req r5
fpp     .req r9
spp     .req r13       @ a64 can't use sp, so everyone else has to suffer
u       .req r7

        @ thumb address must have the lowest bit set to
        @ mark the address as a Thumb instruction set target
        .set   HAS_MACH_FUNC_MARK, 1
        .macro $MACH_FUNC_MARK label
        .type \label, STT_FUNC
        .thumb_func
        .endm

        /* Set IP to the start of the DOES> list */
        .macro $DOES_TARGET
        bic     ipp, lr, 1
        .endm
