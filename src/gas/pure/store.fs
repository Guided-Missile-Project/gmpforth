CODE ! ( x a-addr -- ... store x at a-addr )
        $PTOS   p1
        $PNOS   p2
        $ST     p2, p1
        $PDIS   2
        $NEXT
END-CODE
