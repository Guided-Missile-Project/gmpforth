CODE D+ ( d1 d2 -- d3 ... double add d1+d2 )
        $MOV    t1, pp1          /* d2 upper */
        $PNOS   pp2              /* d2 lower */
        $PDIS   2
        $PNOS   pp1              /* d1 lower */
        $ADD    pp2, pp1, pp2    /* d3l = d1l + d2l */
        $SLTU   t2, pp2, pp1     /* t2 = (d3l u< d1l) ? 1 : 0 (carry) */
        $PTOS   pp1              /* d1 upper */
        $ADD    pp1, pp1, t1     /* d3u' = d1u + d2u */
        $ADD    pp1, pp1, t2     /* d3u = d3u' + carry */
        $S_PNOS pp2
        $NEXT
END-CODE
