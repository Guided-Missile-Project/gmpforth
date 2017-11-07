        .text
        .ifndef DOCOL
        .ifdef _NEED_DOCOL
        .align 16
        .globl DOCOL
DOCOL:  $DOCOL
        .endif
        .endif

        .ifndef DOCON
        .ifdef _NEED_DOCON
        .align 16
        .globl DOCON
DOCON:  $DOCON
        .endif
        .endif

        .ifndef DOVAR
        .ifdef _NEED_DOVAR
        .align 16
        .globl DOVAR
DOVAR:  $DOVAR
        .endif
        .endif

        .ifndef DOUSE
        .ifdef _NEED_DOUSE
        .align 16
        .globl DOUSE
DOUSE:  $DOUSE
        .endif
        .endif


        .ifdef _NEED_DOES
        .align 16
        .globl does
does:
        subq    $_SZ, %rbp   /* push current IP to return stack */
        movq    %rsi, (%rbp)
        movq    (%rsp), %rsi /* set new IP */
        addq    $_SZ, %rax
        movq    %rax, (%rsp) /* make pointer to does> word PFA */
        $NEXT
        .endif

        .data

        .ifdef DOUSE
        .include        "user.inc"
        .endif

        /* parameter stack */
        .bss
        .align 16
        .globl _SPN
_SPN:
        .space  SP_SIZE*_SZ
        .align 16
        .globl _SP0
_SP0:
        /* return stack */
        .space  RP_SIZE*_SZ
        .globl _RP0
_RP0:
        .align 16

        /* _start still needs something to play with if there are
           no user variables */
        .ifndef DOUSE
        .globl _USER
_USER:
        .endif

        /* dictionary */
        .globl _HERE
_HERE:
        .space  DICT_SIZE*_SZ
        .globl _END_DICT
_END_DICT:
