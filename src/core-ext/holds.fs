: HOLDS ( a n -- )
   over + begin 2dup u< while 1- dup c@ hold repeat 2drop ;
