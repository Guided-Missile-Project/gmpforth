: ?STACK ( -- throw errors for stack overflow and underflow )
   \ check for stack underflow
   sp@ (sp0) @ u< if (error-stack-u) throw then
   \ check for stack overflow
   sp@ (sp0) @ SP_SIZE cells + swap u< if (error-stack-o) throw then ;

\ push up stack
\ sp@ (overflow)
\ (sp0)+SP_SIZE
\ ...
\ (sp0)-----
\ sp@ (underflow)
