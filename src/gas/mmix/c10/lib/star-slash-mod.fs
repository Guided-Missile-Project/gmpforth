CODE */MOD ( n1 n2 n3 -- n4 n5 ... {n1*n2}/n3 rem:n4 quo:n5 )
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

        xor     t2, t1, p1      % sign of quotient which is the XOR of all signs
        set     t1, p1          % sign of remainder is sign of divisor
        neg     p3, p1          % negate n3 if needed
        csn     p1, p1, p3      % p1=-p1 if p1<0

        divu    p1, p2, p1      % divide n1*n2 by n3: quo in p1 rem in rR
        get     p2, rR          % rem in p2
        pbnn    t2, 8f          % if sign of quotient is negative

        neg     t2, p2          %   negate remainder if divisor was not negative
        csnn    p2, t1, t2
        add     t1, t1, p2      %   (possibly) add (signed) divisor to remainder
        csnz    p2, p2, t1      %   rem=rem+divisor if rem not zero
        add     t1, p1, 1       %   (possibly) increment quotient
        csnz    p1, p2, t1      %      ...only if remainder is non-zero
        neg     p1, p1          %   negate quotient
        jmp     9f              % then
8:                              % sign of quotient is not negative
        neg     t2, p2          % negate remainder if divisor was negative
        csn     p2, t1, t2
9:
        $PDIS                   % discard n3
        $S_PNOS p2              % save remainder
        $NEXT
END-CODE
