CODE UM/MOD ( ud u1 -- u2 u3 ... ud/u1 rem:u2 quo:u3 )
        $PTOS   p1      % u1
        $PNOS   p2      % ud high
        $P3OS   p3      % ud low
        $PDIS
        put     rD, p2
        divu    p1, p3, p1 % p2 = ud/u1 rem: rR
        get     p2, rR
        $S_PTOS p1      % quotient
        $S_PNOS p2      % remainder
        $NEXT
END-CODE
