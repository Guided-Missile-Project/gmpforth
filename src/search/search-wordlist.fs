: SEARCH-WORDLIST ( addr n wid -- 0 | xt 1 | xt -1 )
   (search-wordlist) dup if (lex-immediate) and if 1 else true then then ;

