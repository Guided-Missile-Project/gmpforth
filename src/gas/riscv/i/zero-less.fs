CODE 0< ( x -- flag ...true if x<0 )
        $SLT    pp1, pp1, 0
        $NEG    pp1, pp1
        $NEXT
END-CODE
