CODE 0< ( x -- flag ...true if x<0 )
        slt     pp1, pp1, 0
        neg     pp1, pp1
        $NEXT
END-CODE
