CODE D- ( d1 d2 -- d3 ... double subtract d1-d2 )
        $MOV    t1, pp1          /* d2 upper */
        $PNOS   pp2              /* d2 lower */
        $PDIS   2
        $PNOS   pp1              /* d1 lower */
        $SUB    pp2, pp1, pp2    /* d3l = d1l - d2l */
        $SLTU   t2, pp1, pp2     /* t2 = (d1l u< d3l) ? 1 : 0 (borrow) */
        $PTOS   pp1              /* d1 upper */
        $SUB    pp1, pp1, t1     /* d3u' = d1u - d2u */
        $SUB    pp1, pp1, t2     /* d3u = d3u' - borrow */
        $S_PNOS pp2
        $NEXT
END-CODE
