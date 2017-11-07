: (FIND) ( caddr len -- caddr len 0|xt lex )
   (vocs) context do
     I @
     if ( search )
       2dup I @ (search-wordlist) ?dup if ( found )
         2swap 2drop unloop exit
       then
     then
   (cell) +loop false ;
