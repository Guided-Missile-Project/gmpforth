: D< ( d1 d2 -- tf )
   2 pick over xor 0< if
      \ if the signs of d1 and d2 differ (d1<0 and d2>=0 or d1>=0 and d2<0)
      \ d1<d2 if d1<0
      2drop
   else
      \ signs of d1 and d2 are the same so d1<d2 if (d1-d2)<0
      d-
   then  d0< ;
