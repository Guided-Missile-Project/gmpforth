: (reset) ( -- )
   true dpl !
   tib @ (scratch) @ 2dup 0 0. 2dup (#i) restore-input ( console input )
   throw ;

