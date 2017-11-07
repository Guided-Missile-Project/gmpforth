: ?STACK ( -- throw errors for stack overflow and underflow )
   \ check for stack underflow
   sp@ (sp0) @ swap u< if (error-stack-u) throw then
   \ check for stack overflow
   sp@ (sp0) @ SP_SIZE cells - u< if (error-stack-o) throw then ;

\ push down stack
\ sp@ (underflow)
\ (sp0)-----
\ ...
\ (sp0)+SP_SIZE
\ sp@ (overflow)
