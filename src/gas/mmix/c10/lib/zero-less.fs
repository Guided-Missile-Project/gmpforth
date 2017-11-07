CODE 0< ( x -- flag ...true if x<0 )
        zsn     p1, p1, 1
        neg     p1, p1
        $NEXT
END-CODE
