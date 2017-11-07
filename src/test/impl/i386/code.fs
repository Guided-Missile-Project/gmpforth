\ Hayes test for i386 code ;code end-code
\ Copyright (c) 2013 by Daniel Kelley

TESTING i386 code words

HEX

\ --------------------------------------------------------------------

TESTING code

CODE MYDUP AD2434FF , 20FF , END-CODE

T{ 1 MYDUP -> 1 1 }T

TESTING ;code

\ variable             dovar+next
: VAR CREATE 1 , ;CODE 5004C083 , 20FFAD , END-CODE
VAR BAR
T{ BAR @ -> 1 }T

CR .( End of i386 code word tests) CR


