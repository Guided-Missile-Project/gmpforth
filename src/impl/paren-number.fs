: (NUMBER) ( d1|n1 n2 -- d1|n1|nothing throw-code )
   state @ if
     2 = if swap postpone literal then
     postpone literal
   else
     drop ( n2 )
   then 0 ; compile-only
