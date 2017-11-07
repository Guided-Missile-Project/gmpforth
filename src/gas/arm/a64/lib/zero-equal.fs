CODE 0= ( x -- flags )
        cmp     pp1, 0
        mov     pp1, -1
        beq     1f
        mvn     pp1, pp1
1:
        $NEXT
END-CODE
