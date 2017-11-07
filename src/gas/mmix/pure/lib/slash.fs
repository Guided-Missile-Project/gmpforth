CODE / ( n1 n2 -- n3 ...n1/n2 )
        $PTOS   p1      % n2 = divisor
        $PNOS   p2      % n1 = dividend
        $PDIS
        div     p1, p2, p1
        $S_PTOS p1
        $NEXT
END-CODE
