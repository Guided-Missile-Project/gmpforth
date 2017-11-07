: MOVE ( a1 a2 u -- )
   >r 2dup swap dup r@ + within r> swap if cmove> else cmove then ;

