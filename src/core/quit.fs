: QUIT ( -- )
   postpone [
   (rp0) @ rp!
   begin
     ['] (quit) catch if recurse then
   again ;
