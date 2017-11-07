: [IF] ( flag -- )
  0= if
    \ if flag is false, parse until a matching [then], skipping nested [if]s
    \ and refilling when needed.
    0 >r ( nesting level )
    begin
      parse-name ?dup if
        2dup s" [if]" casecompare 0= if
          2drop r> 1+ >r false
        else
        2dup s" [else]" casecompare 0= if
          \ flakey: this should be an error if [else]
          \ was followed by [else] - ignore for now
          2drop r@ 0=
        else
        2dup s" [then]" casecompare 0= if
          2drop r@ 0= r> 1- >r 
        else
          2drop ( $) false \ ignore other tokens and continue
        then then then
      else
        drop refill 0=
      then
    until
    r> drop
  then ; immediate
