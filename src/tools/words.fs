: words ( -- )
    0 ( cols) >r context @
    begin
       ?dup
    while
       @ ?dup
    while
      dup l>name dup c@ (lex-start) and if
        (name$) r> over 1+ - dup 0<
        if drop cr 79 ( cols minus a space ) over - then >r
        type space
      else
        drop ( smudged )
      then
    repeat then r> drop ;
