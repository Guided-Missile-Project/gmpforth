\ adjust wid so such that the wordlist and name do not point after addr
: (FORGET-WID) ( addr wid -- )
   \ trim wordlist to definition before addr
   dup >r @
   begin
     2dup > 0= over 0<> and
   while
     @
   repeat
   r@ !

   \ clear name if beyond addr
   r> cell+ cell+
   dup @ rot >
   if 0 swap ! else drop then ;

