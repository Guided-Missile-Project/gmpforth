: GET-ORDER ( -- wid... n )
   0 context current cell- do
     i @ ?dup if swap 1+ then
   (cell) negate +loop ;
