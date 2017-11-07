: (",) ( a n -- )
    dup >r c, here r@ cmove r> allot
    here aligned here - 0 ?do 0 c, loop ;

