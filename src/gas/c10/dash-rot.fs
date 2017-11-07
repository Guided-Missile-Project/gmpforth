CODE -ROT ( n1 n2 n3 -- n3 n1 n2 )
        $MOV    pp3, pp1
        $PNOS   pp1
        $P3OS   pp2
        $S_P3OS pp3
        $S_PNOS pp2
        $NEXT
END-CODE
