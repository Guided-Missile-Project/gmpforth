: >NUMBER ( ud1 c1 n1 -- ud2 c2 n2 )
    dup 0 ?do
      over c@ base @ digit 0= ?leave
        \ valid digit
        >r 2swap base @ um*         \ multiply high part by base
        drop r> swap rot            \ fold in digit
        base @ um*                  \ multiply low part by base
        d+                          \ accumulate digit
        2swap 1 /string             \ advance string
    loop ;

