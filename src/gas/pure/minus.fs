CODE - ( n1 n2 -- n3 ...n1-n2 )
        $PTOS   p1          % n2
        $PNOS   p2          % n1
        $SUB    p1, p2, p1
        $PDIS
        $S_PTOS p1
        $NEXT
END-CODE
