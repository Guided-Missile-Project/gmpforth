CODE N>R ( i*x n -- ...push n and n cells on pstack to rstack )
        $PDIS
        set     t1, p1
1:
        $PPOP   r1
        $RPUSH  r1
        sub     t1, t1, 1
        pbnz    t1, 1b
        $RPUSH  p1
        $PTOS   p1              % refresh p1
        $NEXT
END-CODE
COMPILE-ONLY
