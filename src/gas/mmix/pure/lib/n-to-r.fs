CODE N>R ( i*x n -- ...push n and n cells on pstack to rstack )
        $PPOP   p1
        set     t1, p1
1:
        $PPOP   r1
        $RPUSH  r1
        sub     t1, t1, 1
        bnz     t1, 1b
        $RPUSH  p1
        $NEXT
END-CODE
COMPILE-ONLY
