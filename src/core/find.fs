: FIND ( c-addr -- c-addr 0 | xt 1 | xt -1 )
   dup count (find) dup
   if (lex-immediate) and if 1 else true then rot drop
   else -rot 2drop then ;
