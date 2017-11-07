CODE SWAP ( n1 n2 -- n2 n1 )
        $PTOS   p2
        $PNOS   p1
        $S_PTOS p1
        $S_PNOS p2
        $NEXT
END-CODE
