: (?NAME) ( addr len -- addr len )
  ?dup 0= if (error-no-name) throw then
   dup (lex-max-name) > if (error-def-o) throw then ;

