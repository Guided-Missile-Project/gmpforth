        %
        % Parameter Stack Operations for MMIX pure (non-cached) memory stack
        %

        % push a small constant 'n' onto the parameter stack
        .macro $PUSH n
         $XPUSH sp, \n
        .endm

        % push entity 'e' to parameter stack
        .macro $PPUSH e
        $PUSH \e
        .endm

        % discard n items from top of parameter stack
        .macro $PDIS n=1
        $XDISCARD sp, \n
        .endm

        % append n items to parameter stack
        .macro $PPND n=1
        $XAPPEND sp, \n
        .endm

        % pop entity 'e' from parameter stack
        .macro $PPOP e
        $XPOP   sp, \e
        .endm

        % set entity 'e' to 'n'th element from parameter stack
        .macro $PPICK e n
        $XPICK  sp, \e, \n
        .endm

        % set entity 'e' to TOS (first element) from parameter stack
        .macro $PTOS e
        $XTOS   sp, \e
        .endm

        % set entity 'e' to NOS (second element) from parameter stack
        .macro $PNOS e
        $XNOS   sp, \e
        .endm

        % set entity 'e' to the third element from parameter stack
        .macro $P3OS e
        $X3OS   sp, \e
        .endm

        % set entity 'e' to TOS (first element) from parameter stack
        .macro $S_PTOS e
        $X_S_TOS sp, \e
        .endm

        % set entity 'e' to NOS (second element) from parameter stack
        .macro $S_PNOS e
        $X_S_NOS sp, \e
        .endm

        % set entity 'e' to the third element from parameter stack
        .macro $S_P3OS e
        $X_S_3OS sp, \e
        .endm

        %
        % Return Stack Operations
        %

        % push entity 'e' to return stack
        .macro $RPUSH e
        $XPUSH rp, \e
        .endm

        % discard n items from top of return stack
        .macro $RDIS n=1
        $XDISCARD rp, \n
        .endm

        % append n items to return stack
        .macro $RPND n=1
        $XAPPEND rp, \n
        .endm

        % pop entity 'e' from return stack
        .macro $RPOP e
        $XPOP rp, \e
        .endm

        % set entity 'e' to 'n'th element from return stack
        .macro $RPICK e n
        $XPICK  rp, \e, \n
        .endm

        % set entity 'e' to TOS (first element) from return stack
        .macro $RTOS e
        $XTOS   rp, \e
        .endm

        % set entity 'e' to NOS (second element) from return stack
        .macro $RNOS e
        $XNOS   rp, \e
        .endm

        % set entity 'e' to the third element from return stack
        .macro $R3OS e
        $X3OS   rp, \e
        .endm

        % set entity 'e' to TOS (first element) from return stack
        .macro $S_RTOS e
        $X_S_TOS rp, \e
        .endm

        % set entity 'e' to NOS (second element) from return stack
        .macro $S_RNOS e
        $X_S_NOS rp, \e
        .endm

        % set entity 'e' to the third element from return stack
        .macro $S_R3OS e
        $X_S_3OS rp, \e
        .endm

        %
        % Stack model dependent macros
        %

        .macro $DOES_HANDLER
        .globl does_handler
does_handler:
        $RPUSH  ip
        set     ip, _DOES_LINK_REG
        addu    w, w, _SZ
        $PPUSH  w
        $NEXT
        .endm

        .macro $DOCOL
        .set _HAS_DOCOL, 1
        .if _TRACE_COLON
        $SHOW_W
        add     __colon_indent, __colon_indent, 1
        .else
        .if _TRACE_COLON_NOP
        swym
        .endif
        .endif
        $BLOCK
        $RPUSH  ip
        addu    w, w, _SZ
        set     ip, w
        $NEXT
        $ENDCODE
        .endm

        .macro $UNNEST
        .if _TRACE_COLON
        sub __colon_indent, __colon_indent, 1
        .else
        .if _TRACE_COLON_NOP
        swym
        .endif
        .endif
        $RPOP   ip
        .endm

        .macro $DOCON
        .set _HAS_DOCON, 1
        $BLOCK
        ldo     p1, w, _SZ % get constant value
        $PPUSH  p1
        $NEXT
        $ENDCODE
        .endm

        .macro $DOVAR
        .set _HAS_DOVAR, 1
        $BLOCK
        addu    w, w, _SZ
        $PPUSH  w
        $NEXT
        $ENDCODE
        .endm

        .macro $DOUSE
        .set _HAS_DOUSE, 1
        $BLOCK
        ldo     p1, w, _SZ
        addu    p1, p1, u
        $PPUSH  p1
        $NEXT
        $ENDCODE
        .endm

