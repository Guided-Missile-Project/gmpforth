CODE / ( n1 n2 -- n3 ...n1/n2 )
        $PNOS   p2      % n1 = dividend
        $PDIS
        div     p1, p2, p1
        $NEXT
END-CODE
