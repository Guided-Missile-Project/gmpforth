\ Hayes test for Tools

TESTING Tool words

DECIMAL

TESTING ?

T{ 1234 BASE ? -> 1234 }T

TESTING .S

T{ 1234 5678 .S -> 1234 5678 }

TESTING DUMP

T{ ' COLD 10 DUMP -> }T

TESTING WORDS

\ add smudged definition

: foo foo ;

T{ WORDS -> }T

CR .( End of Tools tests) CR
