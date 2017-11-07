\ convert a syscall negative error to a throwable exception code
: (ior) ( u -- u' )
   dup IO_MAX_ERRORNO 0 within if IO_ERRNO_EXCEPTION + else drop 0 then ;
