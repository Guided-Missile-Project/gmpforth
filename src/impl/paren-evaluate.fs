: (EVALUATE) ( -- )
    begin
      parse-name ?dup
    while
      (find)
      ?dup if ( in dictionary )
        (word)
      else
        number? ?dup if
          (number)
        else
          (error-undef)
        then
      then
      throw
    repeat  drop ( addr ) ?stack ;

