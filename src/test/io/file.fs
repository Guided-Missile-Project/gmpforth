TESTING File words

DECIMAL

TESTING open-file

VARIABLE IOR
VARIABLE FID

S" src/test/io/file-test.fs" R/O OPEN-FILE IOR ! FID !

T{ IOR @ 0= -> TRUE }T

T{ FID @ 0 > -> TRUE }T

T{ S" src/test/io/no-file-test.fs" R/O OPEN-FILE NIP 0 < -> TRUE }T

TESTING FILE-SIZE

T{ FID @ FILE-SIZE -> 26. 0 }T

TESTING CLOSE-FILE

T{ FID @ CLOSE-FILE -> 0 }T

CR .( End of File word tests) CR

