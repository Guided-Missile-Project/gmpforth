
        /* push a small constant 'n' onto the parameter stack */
        .macro $PUSH n
         $XPUSH sp, \n
        .endm

        /* push entity 'e' to parameter stack */
        .macro $PPUSH e
        $PUSH \e
        .endm

        /* discard n items from top of parameter stack */
        .macro $PDIS n=1
        $XDISCARD sp, \n
        .endm

        /* append n items to parameter stack */
        .macro $PPND n=1
        $XAPPEND sp, \n
        .endm

        /* pop entity 'e' from parameter stack */
        .macro $PPOP e
        $XPOP   sp, \e
        .endm

        /* set entity 'e' to 'n'th element from parameter stack */
        .macro $PPICK e n
        $XPICK  sp, \e, \n
        .endm

        /* set entity 'e' to TOS (first element) from parameter stack */
        .macro $PTOS e
        $XTOS   sp, \e
        .endm

        /* set entity 'e' to NOS (second element) from parameter stack */
        .macro $PNOS e
        $XNOS   sp, \e
        .endm

        /* set entity 'e' to the third element from parameter stack */
        .macro $P3OS e
        $X3OS   sp, \e
        .endm

        /* set entity 'e' to TOS (first element) from parameter stack */
        .macro $S_PTOS e
        $X_S_TOS sp, \e
        .endm

        /* set entity 'e' to NOS (second element) from parameter stack */
        .macro $S_PNOS e
        $X_S_NOS sp, \e
        .endm

        /* set entity 'e' to the third element from parameter stack */
        .macro $S_P3OS e
        $X_S_3OS sp, \e
        .endm

        /*
          Return Stack Operations
        */

        /* push entity 'e' to return stack */
        .macro $RPUSH e
        $XPUSH rp, \e
        .endm

        /* discard n items from top of return stack */
        .macro $RDIS n=1
        $XDISCARD rp, \n
        .endm

        /* append n items to return stack */
        .macro $RPND n=1
        $XAPPEND rp, \n
        .endm

        /* pop entity 'e' from return stack */
        .macro $RPOP e
        $XPOP rp, \e
        .endm

        /* set entity 'e' to 'n'th element from return stack */
        .macro $RPICK e n
        $XPICK  rp, \e, \n
        .endm

        /* set entity 'e' to TOS (first element) from return stack */
        .macro $RTOS e
        $XTOS   rp, \e
        .endm

        /* set entity 'e' to NOS (second element) from return stack */
        .macro $RNOS e
        $XNOS   rp, \e
        .endm

        /* set entity 'e' to the third element from return stack */
        .macro $R3OS e
        $X3OS   rp, \e
        .endm

        /* set entity 'e' to TOS (first element) from return stack */
        .macro $S_RTOS e
        $X_S_TOS rp, \e
        .endm

        /* set entity 'e' to NOS (second element) from return stack */
        .macro $S_RNOS e
        $X_S_NOS rp, \e
        .endm

        /* set entity 'e' to the third element from return stack */
        .macro $S_R3OS e
        $X_S_3OS rp, \e
        .endm

        /*
          Stack model dependent macros
        */

        .macro $DOES_HANDLER
        .globl does_handler
does_handler:
        $S_PTOS pp1     /* save current TOS */
        $PPND
        $ADD    pp1, w, _SZ
        $RPUSH  ipp
        $DOES_TARGET
        $DO_NEXT
        .endm

        .macro $DOCOL
        .set _HAS_DOCOL, 1
        $BLOCK
        $RPUSH  ipp
        $ADD    w, w, _SZ
        $MOV    ipp, w
        $NEXT
        $ENDCODE
        .endm

        .macro $UNNEST
        $RPOP   ipp
        .endm

        .macro $DOCON
        .set _HAS_DOCON, 1
        $BLOCK
        $S_PTOS pp1         /* save current TOS; make room for new TOS */
        $PPND
        $LD     pp1, w, _SZ /* get constant value */
        $NEXT
        $ENDCODE
        .endm

        .macro $DOVAR
        .set _HAS_DOVAR, 1
        $BLOCK
        $S_PTOS pp1         /* save current TOS; make room for new TOS */
        $PPND
        $ADD    pp1, w, _SZ
        $NEXT
        $ENDCODE
        .endm

        .macro $DOUSE
        .set _HAS_DOUSE, 1
        $BLOCK
        $S_PTOS pp1         /* save current TOS; make room for new TOS */
        $PPND
        $LD     pp1, w, _SZ
        $ADD    pp1, pp1, u
        $NEXT
        $ENDCODE
        .endm

