: PREVIOUS ( -- )
   \ can pop wordlist?
   context cell+ @ 0= if (error-search-u) throw then
   \ move context down
   context dup cell+ swap current cell- over - move
   \ clear last context entry
   0 current cell- ! ;
