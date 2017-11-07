TESTING IO implementation words

DECIMAL

TESTING include"

include" src/test/io/include-quote-test.fs"

T{ include-quote-tested -> -1 }T

TESTING (io) words

T{ -16 (io) -> 0 }T
T{ (utx?)   -> -1 }T
T{ (urx?)   -> -1 }T

CR .( End of IO Implementation word tests) CR
