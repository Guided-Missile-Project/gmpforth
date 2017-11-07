CODE * ( n1 n2 -- n3 ...n1*n2 )
        $PNOS   p2
        $PDIS
        mul     p1, p2, p1
        $NEXT
END-CODE
