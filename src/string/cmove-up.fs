: CMOVE> ( a1 a2 u -- )
    1- dup >r over + rot r> + -rot ?do dup c@ I c! 1- -1 +loop drop ;

