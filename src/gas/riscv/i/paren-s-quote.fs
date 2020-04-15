CODE (s") ( -- c-addr u )
        $S_PTOS pp1
        $LDB    pp1, ipp        /* read count byte */
        $ADD    s2, ipp, 1      /* point to characters following count */
        $PPUSH  s2              /*  and push */
        $PPND                   /* push string length */
        $ADD    t1, pp1, 1      /*  add 1 for the length byte itself */
        $RALIGN t1              /* align to cell boundry */
        $SKIP   t1              /* move ip to cell following string */
        $NEXT
END-CODE
COMPILE-ONLY

