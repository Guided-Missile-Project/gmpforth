CODE ROT ( n1 n2 n3 -- n2 n3 n1 )
        $PTOS   p2         % n3
        $PNOS   p3         % n2
        $P3OS   p1         % n1
        $S_PTOS p1
        $S_PNOS p2
        $S_P3OS p3
        $NEXT
END-CODE
