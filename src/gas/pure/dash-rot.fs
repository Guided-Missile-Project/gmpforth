CODE -ROT ( n1 n2 n3 -- n3 n1 n2 )
        $PTOS   p3
        $PNOS   p1
        $P3OS   p2
        $S_P3OS p3
        $S_PNOS p2
        $S_PTOS p1
        $NEXT
END-CODE
