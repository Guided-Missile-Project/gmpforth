CODE 0= ( x -- flags )
        cmp     pp1, 0
        mov     pp1, -1
        it      ne
        mvnne   pp1, pp1
        $NEXT
END-CODE
