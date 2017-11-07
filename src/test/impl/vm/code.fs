\ Hayes test for vm code ;code end-code
\ Copyright (c) 2013 by Daniel Kelley

TESTING vm code words

HEX

\ --------------------------------------------------------------------

TESTING code

CODE MYDUP 51 , END-CODE

T{ 1 MYDUP -> 1 1 }T

TESTING ;code

\ variable             dovar+next
: VAR CREATE 1 , ;CODE 64 , END-CODE
VAR BAR
T{ BAR @ -> 1 }T

CR .( End of vm code word tests) CR


