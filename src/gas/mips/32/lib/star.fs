CODE * ( n1 n2 -- n3 ...n1*n2 )
        $PNOS   pp2
        $PDIS
        $MULS   pp1, pp2, pp1
        $NEXT
END-CODE
