: (;code) ( -- )
    \ set cfa of latest to cell following the caller
    \ of this word (conveniently on the return stack)
    \ and exit to caller. ARM Thumb addresses are
    \ required to have bit 0 set.
    r> 1+ ( thumbify addr) latest name> ! ;
COMPILE-ONLY

