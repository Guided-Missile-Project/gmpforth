\ convert character 'c' to digit 'n' in base if 'c' is valid for the base
: DIGIT ( c base -- n -1 | 0 )
   swap toupper [char] 0 -
   dup 0< 0= over 10 17 within 0= and if \ valid: >= '0' && <= '9' || >= 'A'
     dup 16 > if 7 - then \ close gap between '9' and 'A'
     dup rot < if
       true   \ valid because digit is less than base
     else
       drop false \ character beyond limit established by base
     then
   else
     2drop false  \ character less than '0'
   then ;

