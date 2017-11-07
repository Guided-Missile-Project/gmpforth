\ case insensitive compare
: CASECOMPARE ( a1 n1 a2 n2 -- -1|0|+1 )
    2swap       \ a2 n2 a1 n1
    rot         \ a2 a1 n1 n2
    2dup        \ a2 a1 n1 n2 n1 n2
    -           \ a2 a1 n1 n2 n1-n2=dl(delta length)
    >r          \ a2 a1 n1 n2
    min 0       \ a2 a1 n' 0
    dup         \ a2 a1 n' 0 dc=0 (delta character, initial flag setting)
    -rot        \ a2 a1 dc n' 0
    \ loop while characters are equal
    ?do         \ a2 a1 dc
      drop      \ a2 a1
      2dup      \ a2 a1 a2 a1
      c@        \ a2 a1 a2 (a1)
      toupper   \ a2 a1 a2 (a1)
      swap c@   \ a2 a1 (a1) (a2)
      toupper   \ a2 a1 (a1) (a2)
      -         \ a2 a1 (a1)-(a2)=dc
      dup       \ a2 a1 dc dc
      ?leave    \ a2 a1 dc
        rot     \ a1 dc a2
        char+   \ a1 dc a2'
        rot     \ dc a2' a1
        char+   \ dc a2' a1'
        rot     \ a2' a1' dc
    loop
    r>          \ a2 a1 dc dl
    2swap 2drop \ dc dl
    \ work out which flag needs to be tested:
    \  dl=0? - test dc
    \  dl<>0?
    \    dc=0? - test dl
    \    dc<>0? - test dc
    dup         \ dc dl dl
    0=          \ dc dl dl=0?
    if          \ dc dl
      drop      \ dc        :: string lengths equal, use character difference
    else        \ dc dl
      over      \ dc dl dc
      0=        \ dc dl dc=0?
      if        \ dc dl     :: chars same, use string length difference
        swap    \ dl dc
      then      \ d(c|l) d(l|c)
      drop      \ dx        :: drop what's not being tested
    then        \ dx
    sgn ;       \ dx'

