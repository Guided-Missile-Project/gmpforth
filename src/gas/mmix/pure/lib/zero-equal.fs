CODE 0= ( x -- flags )
        $PTOS   p1
        zsz     p1, p1, 1
        neg     p1, p1
        $S_PTOS p1
        $NEXT
END-CODE
