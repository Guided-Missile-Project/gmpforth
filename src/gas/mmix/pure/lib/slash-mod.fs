CODE /MOD ( n1 n2 -- n3 n4 ... n1/n2 rem:n3 quo:n4 )
        $PTOS   p1      % n2 = divisor
        $PNOS   p2      % n1 = dividend
        div     p1, p2, p1
        get     p2, rR
        $S_PNOS p2
        $S_PTOS p1
        $NEXT
END-CODE
