CODE C@ ( addr -- char ...get char at addr )
        $PTOS   p1
        $LDB    p1, p1
        $S_PTOS p1
        $NEXT
END-CODE
