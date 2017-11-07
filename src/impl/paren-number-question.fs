: (NUMBER?) ( addr len -- d 2 | n 1 | 0 )
   over c@ [char] - = dup >r -rot ( save ) r> if
     1 /string ( skip over sign )
     dup 0= if 2drop drop 0 exit ( only '-' is not a number ) then
   then
   0. 2swap >number
   ?dup if ( could be a double number, or error )
     over c@ [char] . = if ( double number )
       1 /string ( skip over decimal point )
       dup >r ( save dpl )
       >number ( convert the rest )
       if ( it wasn't a double number after all )
         r> drop 2drop 2drop 0 exit
       else ( really was a double number )
         drop ( addr )
         rot d+- ( negate if minus sign found )
         2
       then
       r>
     else
       2drop 2drop drop 0 exit
     then
   else ( single number )
     2drop ( addr, high-double-num )
     swap +- ( negate if minus sign found )
     1
     true ( dpl )
   then
   dpl ! ;
