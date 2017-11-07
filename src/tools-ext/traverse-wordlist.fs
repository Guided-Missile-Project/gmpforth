: TRAVERSE-WORDLIST ( xt wid -- )
   swap >r 
   begin
      ?dup
   while
      @ ?dup
   while
     dup
     l>name dup c@ (lex-start) and if
       r@ rot >r \ get xt, save place in wid on R: so stack is accessible to xt
       execute   \ execute xt
       r> swap   \ recover place in wid, leave continue flag on stack
     else
       drop ( smudged ) true ( keep going )
     then
   while
   repeat then then r> drop ( xt ) ;
