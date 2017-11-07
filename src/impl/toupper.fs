\ convert char to uppercase
: TOUPPER ( c -- c' )
    dup [char] a [char] { within if 32 - then ;

