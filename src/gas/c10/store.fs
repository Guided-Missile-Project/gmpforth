CODE ! ( x a-addr -- ... store x at a-addr )
        $PNOS   pp2
        $ST     pp2, pp1
        $PDIS   2
        $PTOS   pp1
        $NEXT
END-CODE
