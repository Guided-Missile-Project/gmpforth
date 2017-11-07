: (MATCH-NAME) ( addr n lfa -- addr n lfa 0 | xt lex -1 | 0 -1 )
   dup >r if
     ( addr n -- r: lfa )
     r@ l>name count ( addr n name lex --  r: lfa )
     dup (lex-start) and if \ name valid
       ( addr n name lex --  r: lfa)
       (lex-max-name) and ( addr n name count  -- r: lfa)
       2over  ( addr n name count addr n  -- r: lfa)
       casecompare ( addr n tf -- r: lfa)
       if \ name not matched
         ( addr n -- r: lfa)
         false ( addr n 0 -- r: lfa)
       else \ name matched
         ( addr n -- r: lfa)
         2drop ( -- r: lfa)
         r> dup ( lfa lfa --)
         l>name ( lfa nfa -- )
         c@     ( lfa lex -- )
         >r ( lfa -- r: lex )
         link> true ( xt -1 -- r: lex )
       then
     else \ name smudged
       ( addr n name lex -- r: lfa)
       2drop false ( addr n 0 -- r: lfa)
     then
     (  -- addr n 0 | xt lex -1 r: lfa)
   else \ end of list
     ( addr n -- r: 0 )
     2drop r@ 0= ( -1 -- )
   then r> swap ;
