\ Hayes test for Core Extension
\ based on coreexttest.fth
\ Copyright (C) Gerry Jackson 2006, 2007

TESTING Base Core Extension words

DECIMAL

TESTING TRUE FALSE

T{ TRUE  -> 0 INVERT }T
T{ FALSE -> 0 }T

TESTING 2R@

: TRF ( a b -- c d )  2>R 2R@ 2R> 2DROP SWAP ;

T{ -1 1234 5678 TRF -> -1 5678 1234 }T ;

TESTING ?DO

: TQD  0 ?DO I LOOP ;

T{ 1 0 TQD -> 1 }T
T{ 1 1 TQD -> 1 0 }T

\ TESTING REFILL
\ Not testable from this framework

TESTING ROLL

T{ 1 2 3 4 0 ROLL  -> 1 2 3 4 }T
T{ 1 2 3 4 1 ROLL  -> 1 2 4 3 }T
T{ 1 2 3 4 2 ROLL  -> 1 3 4 2 }T
T{ 1 2 3 4 3 ROLL  -> 2 3 4 1 }T

TESTING PICK

T{ 1 2 3 0 PICK -> 1 2 3 3 }T
T{ 1 2 3 1 PICK -> 1 2 3 2 }T
T{ 1 2 3 2 PICK -> 1 2 3 1 }T

TESTING SOURCE-ID
T{ SOURCE-ID -> 0 }T
T{ S" SOURCE-ID" EVALUATE -> -1 }T

CR .( End of Base Core Extension word tests) CR


