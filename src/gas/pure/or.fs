CODE OR ( x1 x2 -- x3 ...x1|x2 )
        $PTOS   p1         % x1
        $PNOS   p2         % x2
        $OR     p1, p2
        $PDIS
        $S_PTOS p1
        $NEXT
END-CODE
