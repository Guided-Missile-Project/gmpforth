: (WORD) ( xt lex -- throw-code )
  dup (lex-compile-only) and state @ 0= and if
    \ compile-only in interpret state
    drop ( xt ) (error-compile-only)
  else
    (lex-immediate) and 0= state @ and
    if compile, else execute then  0
  then ;
compile-only
