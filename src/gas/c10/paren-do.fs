CODE (do) ( n1 n2 -- ... get loop start,limit,leave addr and save to rstack )
        $LIT    w       /* get branch address compiled after (do) */
        $PNOS   pp2     /* get limit */
        $RPUSH  w       /* branch */
        $RPUSH  pp2     /* limit */
        $RPUSH  pp1     /* start=index */
        $PDIS   2       /* discard */
        $PTOS   pp1     /* refresh TOS */
        $NEXT
END-CODE
COMPILE-ONLY

