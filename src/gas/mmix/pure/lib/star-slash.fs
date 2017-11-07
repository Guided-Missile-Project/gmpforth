CODE */ ( n1 n2 n3 -- n4 ... {n1*n2}/n3 )
        $PNOS   p2              % n1
        $P3OS   p3              % n2
        xor     t1, p2, p3      % calculate sign of the dividend
                                %  which is the sign of the product n1*n2
                                %  which is the XOR of the signs of n1*n2
        neg     t2, p2          % negate n1 if needed
        csn     p2, p2, t2      % p2=-p2 if p2<0
        neg     t2, p3          % negate n2 if needed
        csn     p3, p3, t2      % p3=-p3 if p3<0
        mulu    p2, p2, p3      % n1*n2  low in p2, high in rH
                                % have to use mulu b/c mul is not 128 bit product
        get     p3, rH          % transfer high part of mulu to high divisor reg
        put     rD, p3
        $PTOS   p1              % n3
        xor     t2, t1, p1      % sign of quotient which is the XOR of all signs
        set     t1, p1          % sign of remainder is sign of divisor
        neg     p3, p1          % negate n3 if needed
        csn     p1, p1, p3      % p1=-p1 if p1<0

        divu    p1, p2, p1      % divide n1*n2 by n3: quo in p1 rem in rR
        get     p2, rR          % rem in p2
        pbnn    t2, 9f          % if sign of quotient is negative
        add     t1, p1, 1       %   (possibly) increment quotient
        csnz    p1, p2, t1      %      ...only if remainder is non-zero
        neg     p1, p1          %   negate quotient
                                % then
9:
        $PDIS   2               % discard n2, n3
        $S_PTOS p1              % save quotient
        $NEXT
END-CODE
