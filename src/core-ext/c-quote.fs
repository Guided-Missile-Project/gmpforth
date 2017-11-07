\ minimal standards compliant implementation
: C" ( -- c-addr )
  [char] " parse postpone (s") (",) postpone drop postpone 1- ;
immediate compile-only

