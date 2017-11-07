
: (does,) ( -- )
    $eb000000                       ( bl opcode )
    $does_handler$                  ( address of does handler )
      ( relative offset to does handler )
      here cell+ cell+ - 2 rshift $ffffff and
      or ,  ;
