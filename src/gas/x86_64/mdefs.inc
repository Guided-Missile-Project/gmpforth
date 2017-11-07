        .include "const.inc"

        .set BITS_PER_BYTE, 8

        .set SIGN_BIT, ((WORD_SIZE*BITS_PER_BYTE) - 1)

        .set _LINK, 0
        .set _ALIGN, WORD_SIZE
        .set _SZ, WORD_SIZE

        .macro $PUSH n
        pushq $\n
        .endm

        .macro  $ENDCODE
        $TRACE  endcode
        .align  _ALIGN, 0x90
        .endm

        .macro $NEXT
        $TRACE next
        lodsq
        $TRANSFER_CFA
        jmp *(%rax)
        .endm

        .macro $DODOES
        .set _NEED_DOES, 1
        $BLOCK
        nop
        nop
        nop
        $TRANSFER
        call    does
        $TRACE does
        .endm

        .macro $DOCOL
        .set _HAS_DOCOL, 1
        $BLOCK
        subq    $_SZ, %rbp
        movq    %rsi, (%rbp)
        addq    $_SZ, %rax
        movq    %rax, %rsi
        $NEXT
        $ENDCODE
        .endm

        .macro $DOCON
        .set _HAS_DOCON, 1
        $BLOCK
        pushq  _SZ(%rax)
        $NEXT
        $ENDCODE
        .endm

        .macro $DOVAR
        .set _HAS_DOVAR, 1
        $BLOCK
        addq    $_SZ, %rax
        pushq   %rax
        $NEXT
        $ENDCODE
        .endm

        .macro $DOUSE
        .set _HAS_DOUSE, 1
        $BLOCK
        movq    _SZ(%rax), %rax
        addq    %r13, %rax
        pushq   %rax
        $NEXT
        $ENDCODE
        .endm

        .macro  $RALIGN x
        $BLOCK
        movq    $_ALIGN, %rax
        subq    \x, %rax
        andq    $_SZ-1, %rax
        addq    %rax, \x
        .endm
