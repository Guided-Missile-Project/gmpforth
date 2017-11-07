\ Hayes test for Search

TESTING Base Tools Search

TESTING SEARCH-WORDLIST

' CATCH CONSTANT 'CATCH

T{ S" CATCH" CONTEXT @ SEARCH-WORDLIST -> 'CATCH -1  }T

TESTING WORDLIST

\ wordlist
\  check:
\    first cell is empty
\    second cell is linked to (vocs)
\    third cell is empty
\

T{ (VOCS) @ WORDLIST DUP @ 0= -ROT DUP CELL+ @ ROT = SWAP 2 CELLS + @ 0=
   -> -1 -1 -1 }T

\ allocated something in dict   
T{ HERE WORDLIST HERE = SWAP HERE = -> 0 0 }T

CR .( End of Base Search word tests) CR

