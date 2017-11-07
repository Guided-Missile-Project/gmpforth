CODE (0branch) ( x -- )
        $LIT    t1              % branch address
        csz     ip, p1, t1      % branch if 'p1' zero
        $PDIS
        $PTOS   p1              % refresh TOS
        $NEXT
END-CODE
COMPILE-ONLY
