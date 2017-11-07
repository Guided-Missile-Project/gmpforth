CODE C! ( char addr -- ...store char at addr )
        $PNOS   pp2
        $STB    pp2, pp1
        $PDIS   2
        $PTOS   pp1
        $NEXT
END-CODE
