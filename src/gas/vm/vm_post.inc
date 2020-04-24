_USER:
        .long   34                      /*  0 (#user)   */
        .long   _SOURCE                 /*  1 (src0)    */
        .long   _SCRATCH                /*  2 (srcend)  */
        .long   _SOURCE                 /*  3 (src)     */
        .long   _SOURCE                 /*  4 (src@)    */
        .long   0                       /*  5 (srcid)   */
        .long   0                       /*  6 (#line)   */
        .long   0                       /*  7 >IN-      */
        .long   0                       /*  8 BLK       */
        .long   0                       /*  9 >IN       */
        .long   0                       /* 10 STATE     */
        .long   10                      /* 11 BASE      */
        .long   0                       /* 12 (hld)     */
        .long   _END                    /* 13 (here)    */
        .long   0                       /* 14 (rx?)     */
        .long   0                       /* 15 (rx@)     */
        .long   0                       /* 16 (tx?)     */
        .long   0                       /* 17 (tx!)     */
        .long   0                       /* 18 (boot)    */
        .long   0                       /* 19 (sp0)     */
        .long   0                       /* 20 (rp0)     */
        .long   0                       /* 21 DPL       */
        .long   0                       /* 22 ERF       */
        .long   _SOURCE                 /* 23 TIB       */
        .long   _SCRATCH                /* 24 (scratch) */
        .long   0                       /* 25 (abort"$) */
        .long   forth_pfa               /* 26 CONTEXT   */
        .long   0                       /* 27           */
        .long   0                       /* 28           */
        .long   0                       /* 29           */
        .long   0                       /* 30           */
        .long   0                       /* 31           */
        .long   0                       /* 32           */
        .long   0                       /* 33           */
        .long   forth_pfa               /* 34 CURRENT   */
        .long   forth_pfa               /* 35 (vocs)    */
        .long   0                       /* 36           */
        .long   0                       /* 37           */
        .long   0                       /* 38           */
        .long   0                       /* 39           */
        .long   0                       /* 40           */
        .long   0                       /* 41           */
        .long   0                       /* 42           */
        .long   0                       /* 43           */
        .long   0                       /* 44           */
        .long   0                       /* 45           */
        .long   0                       /* 46           */
        .long   0                       /* 47           */
        .space  64                      /* 48-63        */
_SOURCE:
        .space  256
_SCRATCH:
        .space  256

_END:

        .set    paren_user_default, _USER
        .set    forth_last, _LAST


