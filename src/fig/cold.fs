\ cold start the system

: COLD ( -- )
   rp@ (rp0) !
   ['] (urx?) (rx?) !
   ['] (urx@) (rx@) !
   ['] (utx?) (tx?) !
   ['] (utx!) (tx!) !
   forth definitions
   gmpforth quit ;
