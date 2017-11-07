
: (does,) ( -- )
    $e8909090 , ( nop nop nop call )
    $does$      ( address of does handler )
      here cell+ - , ( relative offset to does handler ) ;
