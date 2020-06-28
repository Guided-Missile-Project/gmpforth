CODE M+ ( d1 n -- d2 ...mixed mode addition d1+n )
        $SAR    t1, pp1,SIGNEXT_SR /* sign extend pp1 into t1 (n-upper) */
        $PDIS
        $PNOS   t2               /* d1-lower */
        $ADD    pp2, pp1, t2     /* d2l = d1l + n-lower */
        $SLTU   t2, pp2, pp1     /* t2 = (d2l u< n-lower) ? 1 : 0 (carry) */
        $PTOS   pp1              /* d1 upper */
        $ADD    pp1, pp1, t1     /* d2u' = d1u + n-upper */
        $ADD    pp1, pp1, t2     /* d2u = d1u' + carry */
        $S_PNOS pp2
        $NEXT
END-CODE
