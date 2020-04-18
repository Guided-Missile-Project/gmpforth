CODE (?do) ( n1 n2 -- ... get loop start,limit,leave addr and save to rstack )
        $LIT    t1              /* get branch address compiled after (do) */
        $PNOS   pp2             /* get limit */
        $BEQ    pp1, pp2, 1f    /* do not loop if index equals limit */
        $RPUSH  t1              /* branch */
        $RPUSH  pp2             /* limit */
        $RPUSH  pp1             /* start=index */
        $JMP    2f
1:
        $MOV    ipp, t1         /* done looping */
2:
        $PDIS   2               /* discard n1 n2 */
        $PTOS   pp1             /* refresh TOS */
        $NEXT
END-CODE
COMPILE-ONLY
