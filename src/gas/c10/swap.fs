CODE SWAP ( n1 n2 -- n2 n1 )
        $MOV    pp2, pp1
        $PNOS   pp1
        $S_PNOS pp2
        $NEXT
END-CODE
