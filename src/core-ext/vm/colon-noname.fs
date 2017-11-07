: :NONAME ( -- xt )          ( a lot of : compilation depends on a name field )
  s" " (create) latest name> ( zero length name )
  $DOCOL$ over !             ( set code field )
  postpone ] ;               ( start compiling )

