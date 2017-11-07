: PARSE ( delim -- addr len )
  0 swap                \ len delim
  dup 0< if
    negate 1+ ['] <     \ negative delim <=
  else
    ['] =               \ positive delim match exactly
  then                  \ len delim xt
  (input) dup >r        \ get input, save addr
  >in @ >in- !          \ save start
  ?do                   \ loop across input
    1 >in +!            \ advance >in
    2dup I c@ -rot      \ len delim xt c delim xt
    execute             \ len delim xt flag
    ?leave              \ delim found
    rot 1+ rot rot      \ advance len
  loop 2drop            \ drop delim xt
  r> swap ;             \ put in order
