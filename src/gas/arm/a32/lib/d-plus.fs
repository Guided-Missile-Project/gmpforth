CODE D+ ( d1 d2 -- d3 ... double add d1+d2 )
                                /* pp1 = d2 upper */
        $PNOS   pp2             /* pp2 = d2 lower */
        $PDIS   2
        $PNOS   t1              /* t1 = d1 lower */
        adds    pp2, t1, pp2    /* pp2 = d3l = d1l + d2l */
        $PTOS   t1              /* t1 = d1 upper */
        adc     pp1, t1, pp1    /* pp1 = d3u' = d1u + d2u + carry */
        $S_PNOS pp2
        $NEXT
END-CODE
