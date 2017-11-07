CODE M+ ( d1 n -- d2 ...mixed mode addition d1+n )
                                /* pp1 = n lower */
        asr     t1, pp1,SIGNEXT_SR /* sign extend pp1 into t1 (n upper) */
        $PDIS
        $PNOS   t2              /* t2=d1 lower */
        adds    pp2, pp1, t2    /* pp2 = d3l = d1l + d2l */
        $PTOS   pp1             /* t1 = d1 upper */
        adc     pp1, pp1, t1    /* pp1 = d3u' = d1u + d2u + carry */
        $S_PNOS pp2
        $NEXT
END-CODE
