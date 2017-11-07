: SET-ORDER ( wid... n -- )
   \ error if too many
   dup cells current context - > if (error-search-o) throw then
   \ clear out context
   context current over - erase
   dup 0< if \ default order
     drop forth
   else
     context swap 0 ?do swap over ! cell+ loop drop
   then ;
