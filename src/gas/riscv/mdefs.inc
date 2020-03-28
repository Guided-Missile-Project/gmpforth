/*
 * Risc V Common Machine definitions
 */
        .include "sdefs.inc"
        .include "const.inc"

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
        $XST     \e, (\x)
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
        nor     \e, $zero, \e
        .endm

        /*
          Simple binary operations
        */

        /* logical AND  e=e&f */
        .macro $AND e f
        and     \e, \e, \f
        .endm

        /* logical OR  e=e|f */
        .macro $OR e f
        or      \e, \e, \f
        .endm

        /* logical XOR  e=e^f */
        .macro $XOR e f
        xor     \e, \e, \f
        .endm


        /* e=f where e is a register and f is a constant */
        .macro $SET e f
        li \e, \f
        .endm

        /* e=f where where e is a register and f is a register */
        .macro $MOV e f
        move   \e, \f
        .endm

        /*
          Load and Store
        */

        /* load byte e at address f */
        .macro $LDB e f
        lbu    \e, (\f)
        .endm

        /* load _SZ word e at address f, or f+g */
        .macro $LD e f g
        .ifb \g
        $XLD    \e, (\f)
        .else
        $XLD    \e, \g(\f)
        .endif
        .endm

        /* store byte e at address f */
        .macro $STB e f
        sb      \e, (\f)
        .endm

        /* store _SZ word e at address f or f+g */
        .macro $ST e f g
        .ifb \g
        $XST    \e, (\f)
        .else
        $XST    \e, \g(\f)
        .endif
        .endm

        /*
          Transfer
        */

        /* Jump to address label 'a' */
        .macro $JMP a
        j       \a
        nop
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
        nop
        .endm

        /* load the next code word into 'w' and advance 'ip' */
        .macro $NEXT
        $TRACE next
        /* Optimized to put 'ip' advance in delay slot */
        $LD w, ipp
        $LD t1, w
        jr  t1
        $SKIP
        .endm

        /* Set IP to the start of the DOES> list */
        .macro $DOES_TARGET
        $MOV    ipp, $ra
        .endm

        .macro $DODOES
        .set _NEED_DOES, 1
        $TRANSFER
        jal  does_handler
        nop
        .endm

        .macro  $RALIGN x
        $BLOCK
        li      w, _ALIGN
        $SUB    w, w, \x
        andi    w, w, _SZ-1
        $ADD    \x, \x, w
        .endm

