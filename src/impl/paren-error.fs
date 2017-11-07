: (error) ( throw-code -- )
   (abort"$) @ 0= and if
     \ set error syndrome if not set already
     \ and throw-code is non-zero
     source drop >in- @ >in @ over - >r + r@
     \ parsing may have left an extra space; remove if so
     2dup + 1- c@ bl = if 1- then
     here c! here 1+ r> cmove
     s"  ? " dup >r here count + swap cmove
     here c@ r> + here c!
     here (abort"$) ! ( " )
   then ;
