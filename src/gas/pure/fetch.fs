CODE @ ( a-addr -- x )
        $PTOS   p1
        $LD     p1, p1
        $S_PTOS p1
        $NEXT
END-CODE
