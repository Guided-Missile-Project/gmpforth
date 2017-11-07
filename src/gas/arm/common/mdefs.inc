/*
 * ARM Common Machine definitions
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
        str     \e, [\x, -(_SZ)]!
        .endm

        /* discard 'n' items from stack 'x' */
        .macro $XDISCARD x n=1
        add     \x, \x, _SZ*\n
        .endm

        /* append 'n' items to stack 'x' */
        .macro $XAPPEND x n=1
        sub     \x, \x, _SZ*\n
        .endm

        /* set entity 'e' to 'n'th element from stack 'x' */
        .macro $XPICK x e n
        ldr     \e, [\x, \n*_SZ]
        .endm

        /* set 'n'th element of stack 'x' to 'e' */
        .macro $XSET x e n
        str     \e, [\x, \n*_SZ]
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
        ldr     \e, [\x], _SZ
        .endm

        /* include stack operations for this machine model */
        .include "stack.inc"
        /*
          Simple Unary Operations
        */

        /* invert bits of entity e */
        .macro $INV e
        mvn     \e, \e
        .endm

        /* arithmetic shift right of entity e (sign propagated) */
        .macro $SAR e
        asr     \e, \e, 1
        .endm

        /* logical right right of entity e (sign zeroed) */
        .macro $SHR e
        lsr     \e, \e, 1
        .endm

        /* logical left left of entity e */
        .macro $SHL e
        lsl     \e, \e, 1
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
        orr     \e, \e, \f
        .endm

        /* logical XOR  e=e^f */
        .macro $XOR e f
        eor     \e, \e, \f
        .endm


        /* addition e=e+f or e=f+g */
        .macro $ADD e f g
        .ifb \g
        add   \e, \e, \f
        .else
        add   \e, \f, \g
        .endif
        .endm


        /* subtraction e=e-f or e=f-g */
        .macro $SUB e f g
        .ifb \g
        sub   \e, \e, \f
        .else
        sub   \e, \f, \g
        .endif
        .endm

        /* set e=f where f is a constant */
        .macro $SET e f
        mov     \e, \f
        .endm

        /* set e=f where f is a register */
        .macro $MOV e f
        $SET   \e, \f
        .endm


        /*
          Load and Store
        */

        /* load byte e at address f */
        .macro $LDB e f
        .ifdef _A64
        /* See $STB */
        .ifc \e,pp1
        ldrb    pp1w, [\f]
        .endif
        .else
        ldrb    \e, [\f]
        .endif
        .endm

        /* load _SZ word e at address f, or f+g */
        .macro $LD e f g
        .ifb \g
        ldr     \e, [\f]
        .else
        ldr     \e, [\f, \g]
        .endif
        .endm

        /* store byte e at address f */
        .macro $STB e f
        .ifdef _A64
        /* Unfortunately, there needs to be a check for every possible register
           used at a data source. Fortunately there's only one for now. */
        .ifc \e,pp2
        strb   pp2w, [\f]
        .endif
        .else
        strb    \e, [\f]
        .endif
        .endm

        /* store _SZ word e at address f */
        .macro $ST e f
        str     \e, [\f]
        .endm

        /*
          Transfer
        */

        /* Jump to address label 'a' */
        .macro $JMP a
        b       \a
        .endm

        /*
          Other Operations
        */

        /* advance ip by 'n' (default _SZ) */
        .macro $SKIP n=_SZ
        add     ipp, ipp, \n
        .endm

        /* set IP to the address IP is pointing to */
        .macro $BRANCH
        ldr     ipp, [ipp]
        .endm

        /* set entity 'e' to inline literal at 'ipp' and increment i */
        .macro $LIT e
        ldr     \e, [ipp], _SZ
        .endm

        /* mark end of a code word */
        .macro  $ENDCODE
        $TRACE  endcode
        .endm

        /* execute the code word that 'w' points to */
        .macro $EXECUTE
        $LD     t1, w           /* get code interpreter addr */
        $TRANSFER_CFA
        .ifdef _A64
        br      t1              /* branch to interpreter */
        .else
        bx      t1              /* branch to interpreter */
        .endif
        .endm

        /* load the next code word into 'w' and advance 'ip' */
        .macro $NEXT
        $TRACE next
        $LIT    w
        $EXECUTE
        .endm

        .macro $DODOES
        .set _NEED_DOES, 1
        $TRANSFER
        .ifdef _A64
        nop                     /* filler to make 64 bits */
        .endif
        bl   does_handler
        .endm

        .macro  $RALIGN x
        $BLOCK
        mov     w, _ALIGN
        sub     w, w, \x
        and     w, w, _SZ-1
        add     \x, \x, w
        .endm

