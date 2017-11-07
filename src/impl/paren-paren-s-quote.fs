: ((s")) ( a1 n1 -- s2 n2 )
    state @ if
      postpone (s") (",)
    else
      \ When interpreting, offset storage by >IN to allow multiple strings.
      \ This makes this word convenient to use with other words that accept
      \ multiple strings as arguments.
      \
      \ For example, (a) marks where >IN is when "123" is parsed and (b) marks
      \ where >IN is when "abc" is parsed.
      \
      \ 0000000000111111 >in
      \ 0123456789012345
      \ s" 123" s" abc" 2drop 2drop (src) @ 256 + 10 dump 
      \ ... 0  0  0  0 31 32 33  0  0  0  0  0 61 62 63  0  ....123.....abc.
      \                         (a)                     (b)
      \ The strings are placed just before the end of the buffer marked by >IN
      \
      (scratch) @ >in @ + over - swap ( str buf len )
      2dup 2>r cmove 2r>
    then ;
