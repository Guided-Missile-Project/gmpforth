: WORDLIST ( -- wid )
   here dup 0 , ( word list )
   (vocs) dup @ , !  ( link into vocabulary list )
   0 , ( name: pointer to nfa or counted string ) ;
