CODE 0< ( x -- flag ...true if x<0 )
        cmp     pp1, 0
        mov     pp1, -1
        it      pl
        mvnpl   pp1, pp1
        $NEXT
END-CODE
