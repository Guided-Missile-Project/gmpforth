CODE * ( n1 n2 -- n3 ...n1*n2 )
        $PTOS   p1
        $PNOS   p2
        $PDIS
        mul     p1, p2, p1
        $S_PTOS p1
        $NEXT
END-CODE
