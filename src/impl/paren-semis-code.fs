: (;code) ( -- )
    \ set cfa of latest to cell following the caller
    \ of this word (conveniently on the return stack)
    \ and exit to caller.
    r> latest name> ! ;
COMPILE-ONLY

