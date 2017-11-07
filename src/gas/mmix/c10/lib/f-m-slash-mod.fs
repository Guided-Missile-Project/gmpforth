CODE FM/MOD ( d n1 -- n2 n3 ... floored division d/n1 to rem n2 quo n3 )
        $PPOP   c       % n1=divisor
        $PTOS   b       % d upper dividend
        $PNOS   a       % d lower dividend
        set     w, c    % save divisor for sign of remainder
        xor     d, b, c % XOR signs of dividend and divisor for sign of quotient
        bnn     c, 1f
        neg     c, c    % negate divisor if needed
1:      bnn     b, 1f
        neg     b, b    % negate dividend if needed
        neg     a, a
1:      put     rD, b   % d upper to special register
        divu    b, a, c % divide: quotient in b, remainder in rR
        bnn     d, 1f
        neg     b, b    % negate quotient if needed
1:      get     a, rR   % handle remainder
        bnn     w, 1f
        neg     a, a
1:      bnn     d, 1f   % if signs of divident and divisor differ
        sub     b, b, 1 % decrement quotient by one
        add     a, w, a % add divisor to remainder
1:      $S_PTOS b       % save quotient
        $S_PNOS a       % save remainder
        $NEXT
END-CODE
