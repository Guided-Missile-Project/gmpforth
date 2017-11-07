\ prepare string a n for evaluation
: ($evaluate) ( a n -- )
   over + 2dup -1 0. 2dup (#i) restore-input throw ;
