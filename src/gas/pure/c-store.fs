CODE C! ( char addr -- ...store char at addr )
        $PTOS   p1
        $PNOS   p2
        $STB    p2, p1
        $PDIS   2
        $NEXT
END-CODE
