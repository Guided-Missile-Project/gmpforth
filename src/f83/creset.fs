: CRESET ( c addr --- ...set bits in byte at address )
  dup >r c@ swap invert and r> c! ;
