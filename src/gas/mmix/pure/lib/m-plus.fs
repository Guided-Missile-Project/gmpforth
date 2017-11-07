CODE M+ ( d1 n -- d2 ...mixed mode addition d1+n )
        $PPOP   p2              % n lower
        sr      t1, p2, SIGNEXT_SR % sign extend p2 into t1 (n upper)
        $PNOS   p1              % d1 lower
        addu    p2, p1, p2      % d3l = d1l + d2l
        cmpu    t2, p2, p1      % check for carry (d3l u< d1l) -1:< 0:= 1:>
        zsn     t2, t2, 1       % carry < 0 ? 1 : 0
        $PTOS   p1              % d1 upper
        addu    p1, p1, t1      % d3u' = d1u + d2u
        addu    p1, p1, t2      % d3u = d3u' + carry
        $S_PTOS p1
        $S_PNOS p2
        $NEXT
END-CODE
