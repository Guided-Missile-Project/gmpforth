CODE + ( n1 n2 -- n3 ...n1+n2 )
        $PTOS   p1
        $PNOS   p2
        $ADD    p1, p2
        $PDIS
        $S_PTOS p1
        $NEXT
END-CODE
