: DU< ( d1 d2 -- tf )
   \ d1 u< d1 if d1-d2 causes a borrow
   2over     \ d1l d1h d2l d2h d1l d1h
   2swap     \ d1l d1h d1l d1h d2l d2h
   d-        \ d1l d1h d3l d3h
   rot       \ d1l d3l d3h d1h
   swap      \ d1l d3l d1h d3h
   2dup <>   \ d1l d3l d1h d3h d1h<>d3h
   if        \ d1l d3l d1h d3h
      2swap  \ d1h d3h d1l d3l ...upper cells not equal so drop lower cells
   then      \ d1l d3l d1h d3h | d1h d3h d1l d3l
   2drop     \ d1l d3l | d1h d3h
   u< ;      \ d1l u< d3l | d1h u< d3h ...test if borrow occured
