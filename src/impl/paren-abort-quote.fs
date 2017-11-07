: (ABORT") ( x c-addr n -- )
  rot ( flag)  if ( aborting )
    drop 1- ( treat c-addr as counted string ) (abort"$) !
    (error-abort") throw
  else
    2drop
  then ;
compile-only

