        .include "const.inc"

        .set BITS_PER_BYTE, 8

        .set SIGN_BIT, ((WORD_SIZE*BITS_PER_BYTE) - 1)

        .set _LINK, 0
        .set _ALIGN, WORD_SIZE
        .set _SZ, WORD_SIZE

        .macro $PUSH n
        pushl $\n
        .endm

        .macro  $ENDCODE
        $TRACE  endcode
        .align  _ALIGN, 0x90
        .endm

        .macro $NEXT
        $TRACE next
        lodsl
        $TRANSFER_CFA
        jmp *(%eax)
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
        subl    $_SZ, %ebp
        movl    %esi, (%ebp)
        addl    $_SZ, %eax
        movl    %eax, %esi
        $NEXT
        $ENDCODE
        .endm

        .macro $DOCON
        .set _HAS_DOCON, 1
        $BLOCK
        pushl  _SZ(%eax)
        $NEXT
        $ENDCODE
        .endm

        .macro $DOVAR
        .set _HAS_DOVAR, 1
        $BLOCK
        addl    $_SZ, %eax
        pushl   %eax
        $NEXT
        $ENDCODE
        .endm

        .macro $DOUSE
        .set _HAS_DOUSE, 1
        $BLOCK
        movl    _SZ(%eax), %eax
        addl    %edi, %eax
        pushl   %eax
        $NEXT
        $ENDCODE
        .endm

        .macro  $RALIGN x
        $BLOCK
        movl    $_ALIGN, %eax
        subl    \x, %eax
        andl    $_SZ-1, %eax
        addl    %eax, \x
        .endm
