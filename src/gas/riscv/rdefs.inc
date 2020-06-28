/*

riscv FORTH abstract register definitions

riscv as assembler does not support register renaming directly so such
renaming must be handled with macro replacement.

There is a macro for each successive potential register argument. If a
register argument does not match an abstract FORTH register, then the
argument is passed through unchanged.  The 'arg' indicates the final
form of the instruction (for load/store offsets), or implicit shift
constants. Every instruction using an abstract FORTH register must
pass through these macros.

Any instruction that uses a renamed register must have a macro for
that instruction. The convention is that instruction insn will have an
associated macro $INSN.

Registers are assigned to minimize conflict with C/Linux register
usage and to facilitate compressed instructions.

The RISCV implementation only caches TOS, so pp2 may be used as a
temporary register.


| Name | Sym  | Compress | Callee | C |  Linux | GMP   |
|      |      |          | Saved? |   |        | Forth |
|------+------+----------+--------+---+--------+-------|
| x0   | zero |          |        |   |        |       |
| x1   | ra   |          |        |   |        |       |
| x2   | sp   |          |        |   |        | spp   |
| x3   | gp   |          |        |   |        |       |
| x4   | tp   |          |        |   |        |       |
| x5   | t0   |          |        |   |        | t0    | macro only
| x6   | t1   |          |        |   |        | t1    |
| x7   | t2   |          |        |   |        | t2    |
| x8   | s0   | y        | y      |   |        | w     |
| x9   | s1   | y        | y      |   |        | ipp   |
| x10  | a0   | y io     |        | * |      1 |       |
| x11  | a1   | y io     |        | * |      2 |       |
| x12  | a2   | y io     |        | * |      3 |       |
| x13  | a3   | y        |        | * |      4 | rp    |
| x14  | a4   | y        |        | * |      5 | pp1   |
| x15  | a5   | y        |        | * |      6 | pp2   |
| x16  | a6   |          |        | * |        |       |
| x17  | a7   |          |        | * | callno |       |
| x18  | s2   |          | y      |   |        |       |
| x19  | s3   |          | y      |   |        |       |
| x20  | s4   |          | y      |   |        |       |
| x21  | s5   |          | y      |   |        | fpp   |
| x22  | s6   |          | y      |   |        | u     |
| x23  | s7   |          | y      |   |        |       |
| x24  | s8   |          | y      |   |        |       |
| x25  | s9   |          | y      |   |        | pp3   |
| x26  | s10  |          | y      |   |        |       |
| x27  | s11  |          | y      |   |        |       |
| x28  | t3   |          |        |   |        | t3    |
| x29  | t4   |          |        |   |        | t4    |
| x30  | t5   |          |        |   |        | t5    |
| x31  | t6   |          |        |   |        | t6    |

 */


        /* op  rd rs1 rs2 arg='ofs|shift'
         *
         * if arg is blank, rs2 is reg
         * if arg is 'ofs'. rs2 is offset; emit rs2(rs1)
         * if arg is 'shift', emit '1' if rs2 is blank otherwise emit rs2
         *
         * convert rd if needed and pass to XOP_RS1
         */
        .macro $XOP op rd rs1 rs2 arg
        .ifc \rd, w
        $XOP_RS1 \op s0, \rs1, \rs2, \arg,
        .else
        .ifc \rd, ipp
        $XOP_RS1 \op s1, \rs1, \rs2, \arg
        .else
        .ifc \rd, rp
        $XOP_RS1 \op a3, \rs1, \rs2, \arg
        .else
        .ifc \rd, spp
        $XOP_RS1 \op sp, \rs1, \rs2, \arg
        .else
        .ifc \rd, fpp
        $XOP_RS1 \op s5, \rs1, \rs2, \arg
        .else
        .ifc \rd, u
        $XOP_RS1 \op s6, \rs1, \rs2, \arg
        .else
        .ifc \rd, pp1
        $XOP_RS1 \op a4, \rs1, \rs2, \arg
        .else
        .ifc \rd, pp2
        $XOP_RS1 \op a5, \rs1, \rs2, \arg
        .else
        .ifc \rd, pp3
        $XOP_RS1 \op s9, \rs1, \rs2, \arg
        .else
        /* as is */
        $XOP_RS1 \op \rd, \rs1, \rs2, \arg
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endm

        /* rd,rs1,rs2,arg - rd converted, convert rs1 */
        .macro $XOP_RS1 op rd rs1 rs2 arg
        .ifc \rs1, w
        $XOP_RS2 \op \rd, s0, \rs2, \arg
        .else
        .ifc \rs1, ipp
        $XOP_RS2 \op \rd, s1, \rs2, \arg
        .else
        .ifc \rs1, rp
        $XOP_RS2 \op \rd, a3, \rs2, \arg
        .else
        .ifc \rs1, spp
        $XOP_RS2 \op \rd, sp, \rs2, \arg
        .else
        .ifc \rs1, fpp
        $XOP_RS2 \op \rd, s5, \rs2, \arg
        .else
        .ifc \rs1, u
        $XOP_RS2 \op \rd, s6, \rs2, \arg
        .else
        .ifc \rs1, pp1
        $XOP_RS2 \op \rd, a4, \rs2, \arg
        .else
        .ifc \rs1, pp2
        $XOP_RS2 \op \rd, a5, \rs2, \arg
        .else
        .ifc \rs1, pp3
        $XOP_RS2 \op \rd, s9, \rs2, \arg
        .else
        /* as is */
        $XOP_RS2 \op \rd, \rs1, \rs2, \arg
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endm

        /* rd,rs1,rs2,arg - rd,rs1 converted, convert rs2 */
        .macro $XOP_RS2 op rd rs1 rs2 arg
        .ifc \rs2, w
        $XOP_EMIT \op, \rd, \rs1, s0, \arg
        .else
        .ifc \rs2, ipp
        $XOP_EMIT \op, \rd, \rs1, s1, \arg
        .else
        .ifc \rs2, rp
        $XOP_EMIT \op, \rd, \rs1, a3, \arg
        .else
        .ifc \rs2, spp
        $XOP_EMIT \op, \rd, \rs1, sp, \arg
        .else
        .ifc \rs2, fpp
        $XOP_EMIT \op, \rd, \rs1, s5, \arg
        .else
        .ifc \rs2, u
        $XOP_EMIT \op, \rd, \rs1, s6, \arg
        .else
        .ifc \rs2, pp1
        $XOP_EMIT \op, \rd, \rs1, a4, \arg
        .else
        .ifc \rs2, pp2
        $XOP_EMIT \op, \rd, \rs1, a5, \arg
        .else
        .ifc \rs2, pp3
        $XOP_EMIT \op, \rd, \rs1, s9, \arg
        .else
        /* as is */
        $XOP_EMIT \op, \rd, \rs1, \rs2, \arg
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endif
        .endm

        /* Emit final instruction form */
        .macro $XOP_EMIT op rd rs1 rs2 arg
        .ifb \rd
          \op
        .else
            .ifb \rs1
              .ifc \arg, shift
                 \op \rd, \rd, 1
              .else
                 \op \rd
              .endif
          .else
            .ifb \rs2
              \op \rd, \rs1
            .else
              .ifc \arg, ofs
                \op \rd, \rs2(\rs1)
              .else
                .ifc \arg, shift
                  .ifb \rs1
                    \op \rd, \rd, 1
                  .else
                    \op \rd, \rs1, \rs2
                  .endif
                .else
                  .ifb \arg
                    \op \rd, \rs1, \rs2
                  .else
                    \op \rd, \rs1, \rs2, \arg
                  .endif
                .endif
              .endif
            .endif
          .endif
        .endif
        .endm
