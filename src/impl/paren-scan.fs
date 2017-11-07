\ scan a string while xt(c) is true for char in string
: (SCAN) ( addr len c xt -- addr' len' )
    2>r
    begin
        dup
    while
        over c@ 2r@ execute
    while
        1 /string
    repeat then 2r> 2drop ;

