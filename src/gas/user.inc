        .ifndef forth_pfa
        .set forth_pfa, 0
        .endif
        .globl _USER
        .set USER_ALLOC, USER_LAST+1
        $ALIGN
_USER:
        $WORD   USER_ALLOC              /*  0 (#user)   */
_USER_PAREN_SRC0:
        $WORD   _SOURCE                 /*  1 (src0)    */
_USER_PAREN_SRCEND:
        $WORD   _SCRATCH                /*  2 (srcend)  */
_USER_PAREN_SRC:
        $WORD   _SOURCE                 /*  3 (src)     */
_USER_PAREN_SRC_AT:
        $WORD   _SOURCE                 /*  4 (src@)    */
_USER_PAREN_SRCID:
        $WORD   0                       /*  5 (srcid)   */
_USER_PAREN_NUMBER_LINE:
        $WORD   0                       /*  6 (#LINE)   */
_USER_TO_IN_MINUS:
        $WORD   0                       /*  7 >IN-      */
_USER_BLK:
        $WORD   0                       /*  8 BLK       */
_USER_TO_IN:
        $WORD   0                       /*  9 >IN       */
_USER_STATE:
        $WORD   0                       /* 10 STATE     */
_USER_BASE:
        $WORD   10                      /* 11 BASE      */
_USER_PAREN_HLD:
        $WORD   0                       /* 12 (hld)     */
_USER_PAREN_HERE:
        $WORD   _HERE                   /* 13 (here)    */
_USER_PAREN_RX_QUESTION:
        $WORD   0                       /* 14 (rx?)     */
_USER_PAREN_RX_FETCH:
        $WORD   0                       /* 15 (rx@)     */
_USER_PAREN_TX_QUESTION:
        $WORD   0                       /* 16 (tx?)     */
_USER_PAREN_TX_STORE:
        $WORD   0                       /* 17 (tx!)     */
_USER_PAREN_BOOT:
        $WORD   0                       /* 18 (boot)    */
_USER_PAREN_SP0:
        $WORD   _SP0                    /* 19 (sp0)     */
_USER_PAREN_RP0:
        $WORD   _RP0                    /* 20 (rp0)     */
_USER_DPL:
        $WORD   0                       /* 21 DPL       */
_USER_ERF:
        $WORD   0                       /* 22 ERF       */
_USER_TIB:
        $WORD   _SOURCE                 /* 23 TIB       */
_USER_PAREN_SCRATCH:
        $WORD   _SCRATCH                /* 24 (scratch) */
_USER_PAREN_ABORT_QUOTE_DOLLAR:
        $WORD   0                       /* 25 (abort"$) */
_USER_CONTEXT:
        $WORD   forth_pfa               /* 26 CONTEXT   */
_USER_CONTEXT_1:
        $WORD   0                       /* 27           */
_USER_CONTEXT_2:
        $WORD   0                       /* 28           */
_USER_CONTEXT_3:
        $WORD   0                       /* 29           */
_USER_CONTEXT_4:
        $WORD   0                       /* 30           */
_USER_CONTEXT_5:
        $WORD   0                       /* 31           */
_USER_CONTEXT_6:
        $WORD   0                       /* 32           */
_USER_CONTEXT_7:
        $WORD   0                       /* 33           */
_USER_CURRENT:
        $WORD   forth_pfa               /* 34 CURRENT   */
_USER_PAREN_VOCS:
        $WORD   forth_pfa               /* 35 (vocs)    */
_USER_EXPANSION:
        .space  (USER_SIZE-USER_ALLOC)*_SZ

_SOURCE:
        .space  TIB_SIZE
_SCRATCH:
        .space  SCRATCH_SIZE

        .set    paren_user_default, _USER
        .set    forth_last, _LAST

        .globl _USER_PAREN_SRC0
        .globl _USER_PAREN_SRCEND
        .globl _USER_PAREN_SRC
        .globl _USER_PAREN_SRC_AT
        .globl _USER_PAREN_SRCID
        .globl _USER_PAREN_NUMBER_LINE
        .globl _USER_TO_IN_MINUS
        .globl _USER_BLK
        .globl _USER_TO_IN
        .globl _USER_STATE
        .globl _USER_BASE
        .globl _USER_PAREN_HLD
        .globl _USER_PAREN_HERE
        .globl _USER_PAREN_RX_QUESTION
        .globl _USER_PAREN_RX_FETCH
        .globl _USER_PAREN_TX_QUESTION
        .globl _USER_PAREN_TX_STORE
        .globl _USER_PAREN_BOOT
        .globl _USER_PAREN_SP0
        .globl _USER_PAREN_RP0
        .globl _USER_DPL
        .globl _USER_ERF
        .globl _USER_TIB
        .globl _USER_PAREN_SCRATCH
        .globl _USER_PAREN_ABORT_QUOTE_DOLLAR
        .globl _USER_CONTEXT
        .globl _USER_CONTEXT_1
        .globl _USER_CONTEXT_2
        .globl _USER_CONTEXT_3
        .globl _USER_CONTEXT_4
        .globl _USER_CONTEXT_5
        .globl _USER_CONTEXT_6
        .globl _USER_CONTEXT_7
        .globl _USER_CURRENT
        .globl _USER_PAREN_VOCS
        .globl _USER_EXPANSION
