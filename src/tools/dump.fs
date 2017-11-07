: DUMP ( a n -- )
   base @ >r hex
   0 ?do
     cr dup I + 2 cells ( actually #chars in 1 cell) u.r space
     16 0 do dup I J + + c@ 3 u.r loop
     2 spaces
     16 0 do dup I J + + c@
       dup 32 127 within 0= if drop [char] . then emit
     loop
   16 +loop
   r> base ! drop ;
