\ Hayes test for F83 words
\ Copyright (c) 2013 by Daniel Kelley

TESTING F83 words

\ --------------------------------------------------------------------

TESTING >LINK

\ assumes ! is the first word in the dictionary
T{ ' ! >link @ -> 0 }T

TESTING BODY>

T{ ' ! dup >body body> = -> -1 }T

CR .( End of F83 word tests) CR


TESTING USER

(#USER) @ 1+ USER UVAR

T{ 2 UVAR ! UVAR @ -> 2 }T

TESTING VOCABULARY

VOCABULARY VOCAB

ALSO VOCAB DEFINITIONS

: VTEST 123 ;

T{ VTEST -> 123 }T

