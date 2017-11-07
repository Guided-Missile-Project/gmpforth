\ Hayes test for x86_64 code ;code end-code
\ Copyright (c) 2013 by Daniel Kelley

TESTING x86_64 code words

HEX

\ --------------------------------------------------------------------

TESTING code

CODE MYDUP 20FFAD482434FF , END-CODE

T{ 1 MYDUP -> 1 1 }T

TESTING ;code

\ variable             dovar+next
: VAR CREATE 1 , ;CODE FFAD485008C08348 , 20 , END-CODE
VAR BAR
T{ BAR @ -> 1 }T

CR .( End of x86_64 code word tests) CR


