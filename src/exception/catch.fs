: CATCH ( x -- 0|n )
   sp@ erf @ 
   swap 2>r      \ save erf, stack pointer 
   rp@ erf !     \ set new error frame pointer 
   execute       \ execute xt 
   2r> drop      \ get previous error frame, drop sp@ 
   erf !         \ restore previous error frame
   false ;       \ no error

