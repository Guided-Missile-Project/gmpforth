: THROW ( n -- )
   ?dup if
     erf @ rp!   \ restore return stack from current error frame
     2r> -rot    \ get previous error frame, sp@
     erf !       \ restore previous error frame
     >r          \ save n because stack is about to be reset
     sp! drop    \ restore stack, drop xt from catch
     r>          \ get n
   then ;

