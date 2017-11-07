CODE ROT ( n1 n2 n3 -- n2 n3 n1 )
        $MOV    pp2, pp1
        $PNOS   pp3
        $P3OS   pp1
        $S_PNOS pp2
        $S_P3OS pp3
        $NEXT
END-CODE
