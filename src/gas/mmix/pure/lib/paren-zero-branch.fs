CODE (0branch) ( x -- )
        $PPOP   p1              % get code
        $LIT    t1              % branch address
        csz     ip, p1, t1      % branch if 'p1' zero
        $NEXT
END-CODE
COMPILE-ONLY
