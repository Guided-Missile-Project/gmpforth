CODE 0< ( x -- flag ...true if x<0 )
        cmp     pp1, 0
        mov     pp1, -1
        bmi     1f
        mvn     pp1, pp1
1:
        $NEXT
END-CODE
