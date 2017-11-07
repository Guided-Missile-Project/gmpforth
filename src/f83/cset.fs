: CSET ( c addr --- ...set bits in byte at address )
  dup >r c@ or r> c! ;
