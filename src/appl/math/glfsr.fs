\ Galois form LFSR function
: glfsr ( state feedback -- state' )
  over 1 and negate     \ state feedback bit -- bit is -1 if state lsb is 1
  and                   \ feedback term: as is if bit is -1 1 else 0
  swap 1 rshift xor ;   \ shift state right and xor feedback term

