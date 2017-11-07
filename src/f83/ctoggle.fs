: CTOGGLE ( c addr --- ...set bits in byte at address )
  dup >r c@ xor r> c! ;
