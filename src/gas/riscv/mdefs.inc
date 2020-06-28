/*
 * Risc V Common Machine definitions
 */
        .include "rdefs.inc"
        .include "sdefs.inc"
        .include "const.inc"
        .include "dict.inc"

        .set BITS_PER_BYTE, 8

        .set BITS_PER_WORD, (WORD_SIZE * BITS_PER_BYTE)
        .set SIGN_BIT, (BITS_PER_WORD - 1)

        .set _LINK, 0
        .set _ALIGN, WORD_SIZE
        .set _SZ, WORD_SIZE

        .set SIGNEXT_SR, ((_SZ*BITS_PER_BYTE)-1)


        /* push entity 'e' to stack 'x' */
        .macro $XPUSH x e
        $XAPPEND \x
        $ST     \e, \x
        .endm

        /* discard 'n' items from stack 'x' */
        .macro $XDISCARD x n=1
        $ADDI    \x, \x, _SZ*\n
        .endm

        /* append 'n' items to stack 'x' */
        .macro $XAPPEND x n=1
        $ADDI    \x, \x, -(_SZ*\n)
        .endm

        /* set entity 'e' to 'n'th element from stack 'x' */
        .macro $XPICK x e n
        $LD      \e, \x, \n*_SZ
        .endm

        /* set 'n'th element of stack 'x' to 'e' */
        .macro $XSET x e n
        $ST     \e, \x, \n*_SZ
        .endm

        /* set entity 'e' to TOS (first element) from stack 'x' */
        .macro $XTOS x e
        $XPICK  \x, \e, 0
        .endm

        /* set entity 'e' to NOS (second element) from stack 'x' */
        .macro $XNOS x e
        $XPICK  \x, \e, 1
        .endm

        /* set entity 'e' to the third element from stack 'x' */
        .macro $X3OS x e
        $XPICK  \x, \e, 2
        .endm

        /* set entity 'e' to TOS (first element) from stack 'x' */
        .macro $X_S_TOS x e
        $XSET   \x, \e, 0
        .endm

        /* set entity 'e' to NOS (second element) from stack 'x' */
        .macro $X_S_NOS x e
        $XSET   \x, \e, 1
        .endm

        /* set entity 'e' to the third element from stack 'x' */
        .macro $X_S_3OS x e
        $XSET   \x, \e, 2
        .endm

        /* pop into entity 'e' from stack 'x' */
        .macro $XPOP x e
        $XTOS  \x \e
        $XDISCARD \x
        .endm

        /* include stack operations for this machine model */
        .include "stack.inc"
        /*
          Simple Unary Operations
        */

        /* invert bits of entity e */
        .macro $INV e
        $XOP xori, \e, \e, -1
        .endm

        /*
          Simple binary operations
        */

        /* logical AND  e=e&f */
        .macro $AND e f
        $XOP and, \e, \e, \f
        .endm

        /* logical AND immediate e=e&f */
        .macro $ANDI e f k
        $XOP andi, \e, \f, \k
        .endm

        /* logical OR  e=e|f */
        .macro $OR e f g
        .ifb \g
        $XOP or, \e, \e, \f
        .else
        $XOP or, \e, \f, \g
        .endif
        .endm

        /* logical XOR  e=e^f */
        .macro $XOR e f g
        .ifb \g
        $XOP xor, \e, \e, \f
        .else
        $XOP xor, \e, \f, \g
        .endif
        .endm


        /* e=f where e is a register and f is a constant */
        .macro $SET e f
        $XOP li, \e, \f
        .endm

        /* e=f where where e is a register and f is a register */
        .macro $MOV e f
        $XOP move, \e, \f
        .endm

        /*
          Load and Store
        */

        /* load byte into e from address in f */
        .macro $LDB e f
        $XLB   \e, \f, 0
        .endm

        /* load _SZ word into e from address in f, or f+k */
        .macro $LD e f k
        .ifb \k
        $XLD    \e, \f, 0
        .else
        $XLD    \e, \f, \k
        .endif
        .endm

        /* load e from address symbol f; uses t0 */
        .macro $LDA e f
        $LA    t0, \f
        $LD    \e, t0
        .endm

        /* store byte in e to address in f */
        .macro $STB e f
        $XSB    \e, \f, 0
        .endm

        /* store _SZ word in e to address in f or f+k */
        .macro $ST e f k
        .ifb \k
        $XST    \e, \f, 0
        .else
        $XST    \e, \f, \k
        .endif
        .endm

        /* store e to address symbol f; uses t0 */
        .macro $STA e f
        $LA    t0, \f
        $ST    \e, t0
        .endm

        /* Store an 8 bit byte in 'e' from register 'x' offset k */
        .macro $XSB e x k
        $XOP sb, \e, \x, \k, ofs
        .endm

        /* Load an 8 bit byte in 'e' from register 'x' offset k */
        .macro $XLB e x k
        $XOP lbu, \e, \x, \k, ofs
        .endm

        /* Load a 32 bit address 'x' in register 'e' */
        .macro $LA e x
        $XOP la, \e, \x
        .endm

        /* Load a small immediate 'x' in register 'e' */
        .macro $LI e x
        $XOP li, \e, \x
        .endm

        /* Add */
        .macro $ADD a b c
        .ifb \c
        $XOP add, \a, \a, \b
        .else
        $XOP add, \a, \b, \c
        .endif
        .endm

        /* Add Immediate */
        .macro $ADDI a b k
        $XOP addi, \a, \b, \k
        .endm

        /* Subtract */
        .macro $SUB a b c
        .ifb \c
        $XOP sub, \a, \a, \b
        .else
        $XOP sub, \a, \b, \c
        .endif
        .endm

        /* Negate */
        .macro $NEG a b
        .ifb \b
        $XOP neg, \a, \a
        .else
        $XOP neg, \a, \b
        .endif
        .endm

        /* Shift left */
        .macro $SHL a b c
        $XOP   slli, \a, \b, \c, shift
        .endm

        /* Shift right logical */
        .macro $SHR a b c
        $XOP   srli, \a, \b, \c, shift
        .endm

        /* Shift right arithmetic */
        .macro $SAR a b c
        $XOP   srai, \a, \b, \c, shift
        .endm

        /* Set if less than unsigned */
        .macro $SLTU a b c
        $XOP   sltu, \a, \b, \c
        .endm

        /* Set if less than */
        .macro $SLT a b c
        $XOP   slt, \a, \b, \c
        .endm

        /* Set if less than immediate */
        .macro $SLTI a b c
        $XOP   slti, \a, \b, \c
        .endm

        /* Set if 0= */
        .macro $SEQZ a b
        $XOP   seqz, \a, \b
        .endm

        /* NxN multiply */
        .macro $MUL a b c
        $XOP   mul, \a, \b, \c, shift
        .endm

        /* NxN multiply high */
        .macro $MULHU a b c
        $XOP   mulhu, \a, \b, \c, shift
        .endm

        /*
          Transfer
        */

        /* Jump to address label 'a' */
        .macro $JMP a
        j       \a
        .endm

        /* Jump via register 'a' */
        .macro $JR a
        $XOP jr, \a
        .endm

        /* branch if r>=0 */
        .macro $BGEZ a b
        $XOP bgez, \a, \b
        .endm

        /* branch if r!=0 */
        .macro $BNEZ a b
        $XOP bnez, \a, \b
        .endm

        /* branch if r==0 */
        .macro $BEQZ a b
        $XOP beqz, \a, \b
        .endm

        /* branch if r<=0 */
        .macro $BLEZ a b
        $XOP blez, \a, \b
        .endm

        /* branch if r<0 */
        .macro $BLTZ a b
        $XOP bltz, \a, \b
        .endm

        /* branch if r>0 */
        .macro $BGTZ a b
        $XOP bgtz, \a, \b
        .endm

        /* branch if a==b */
        .macro $BEQ a b c
        $XOP beq, \a, \b, \c
        .endm

        /* branch if a!=b */
        .macro $BNE a b c
        $XOP bne, \a, \b, \c
        .endm

        /*
          Other Operations
        */

        /* advance ip by _SZ (ir r blank), or given register r */
        .macro $SKIP r
        .ifb   \r
        $ADDI   ipp, ipp, _SZ
        .else
        $ADD    ipp, ipp, \r
        .endif
        .endm

        /* set IP to the address IP is pointing to */
        .macro $BRANCH
        $LD    ipp, ipp
        .endm

        /* set entity 'e' to inline literal at 'ipp' and increment ipp */
        .macro $LIT e
        $LD    \e, ipp
        $SKIP
        .endm

        /* mark end of a code word */
        .macro  $ENDCODE
        $TRACE  endcode
        .endm

        /* execute the code word that 'w' points to */
        .macro $EXECUTE
        $LD     t1, w           /* get code interpreter addr */
        jr      t1              /* branch to interpreter */
        .endm

        /* jump to next handler */
        .macro $NEXT
        $TRACE next
        j do_next
        .endm

        /* load the next code word into 'w' and advance 'ip' */
       .macro $DO_NEXT
       .globl do_next
do_next:
        $LD w, ipp
        $LD pp2, w /* using pp2 as tmp for compressed encoding */
        $SKIP
        $JR pp2
        .endm

        .macro  $RALIGN x
        $BLOCK
        $LI     w, _ALIGN
        $SUB    w, w, \x
        $ANDI   w, w, _SZ-1
        $ADD    \x, \x, w
        .endm

        /* CSR ops */
        .macro $RDCYCLE e
        $XOP    rdcycle, \e
        .endm
