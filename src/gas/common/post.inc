        .text
        .ifndef DOCOL
        .ifdef _NEED_DOCOL
        $ALIGN
        .globl DOCOL
        $MACH_FUNC_MARK DOCOL
DOCOL:  $DOCOL
        .endif
        .endif

        .ifndef DOCON
        .ifdef _NEED_DOCON
        $ALIGN
        .globl DOCON
        $MACH_FUNC_MARK DOCON
DOCON:  $DOCON
        .endif
        .endif

        .ifndef DOVAR
        .ifdef _NEED_DOVAR
        $ALIGN
        .globl DOVAR
        $MACH_FUNC_MARK DOVAR
DOVAR:  $DOVAR
        .endif
        .endif

        .ifndef DOUSE
        .ifdef _NEED_DOUSE
        $ALIGN
        .globl DOUSE
        $MACH_FUNC_MARK DOUSE
DOUSE:  $DOUSE
        .endif
        .endif


        .ifdef _NEED_DOES
        $ALIGN
        .globl does
        $MACH_FUNC_MARK does
does:
        $DOES_HANDLER
        .endif

        .data

        .ifdef DOUSE
        .include        "user.inc"
        .endif

        /* parameter stack */
        .ifndef _NO_BSS
        .bss
        .endif
        $ALIGN
        .globl _SPN
_SPN:
        .space  SP_SIZE*_SZ
        $ALIGN
        .globl _SP0
_SP0:
        .ifdef  SP_SLACK
        .space  SP_SLACK*_SZ
        .endif
        /* return stack */
        .space  RP_SIZE*_SZ
        .globl _RP0
_RP0:
        .ifdef  RP_SLACK
        .space  RP_SLACK*_SZ
        .endif
        $ALIGN

        /* _start still needs something to play with if there are
           no user variables */
        .ifndef DOUSE
        .globl _USER
_USER:
        .endif

        /* dictionary */
        .globl _HERE
        .ifdef _DICT_TEXT
        .text
        .endif
_HERE:
        .space  DICT_SIZE*_SZ
        .globl _END_DICT
_END_DICT:
