: NUMBER? ( addr len -- d 2 | n 1 | 0 )
  base @ >r
  2dup 3 = swap dup c@ [char] ' = swap 1+ 1+ c@ [char] ' = and and if
    ( 'c' form )
    r> 2drop 1+ c@ 1 exit
  then
  dup 1 > if
    \ check for base prefix
    over c@
    dup [char] # = if drop 10 base ! 1 /string else
    dup [char] $ = if drop 16 base ! 1 /string else
    dup [char] % = if drop  2 base ! 1 /string
    else drop
    then then then
  then
  (number?)
  r> base ! ;
