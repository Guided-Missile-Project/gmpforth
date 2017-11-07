: (respond) ( throw-code -- )
   ?dup if
     dup (error-abort) <> (abort"$) @ and if
       \ abort" message if found and not abort )
       (abort"$) @ count type
     then
     dup (error-ABORT") 0 within if
       drop ( no error message for abort )
     else
       ." er" .
     then
     0 (abort"$) !
   else
     state @ 0= if ."  ok" then
   then ;
