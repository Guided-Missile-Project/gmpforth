\
\ Create Thumb branch-and-link to does_handler
\
\ See ARM-v7M Architecture Reference Manual
\ ARM DDI 0403E.b ID120114
\ Section A7.7.18
\
\ Instruction and address fields are notated as follows:
\
\ s=S
\ m=I1
\ n=I2
\ a=imm10
\ b=imm11
\ j=J1
\ k=J2
\
\ instruction encoding
\ 33222222222211111111110000000000
\ 10987654321098765432109876543210
\ 11j1kbbbbbbbbbbb11110saaaaaaaaaa
\
\ address bit sources
\ 33222222222211111111110000000000
\ 10987654321098765432109876543210
\ ssssssssmnaaaaaaaaaabbbbbbbbbbb0


: (does,) ( -- )
    $d000f000                       \ Thumb-2 Encoding T1 bl opcode
    $does_handler$                  \ address of does handler
    here cell+ - >r                 \ relative offset to does handler
    r@ $ffe and 15 lshift or        \ prep and combine imm11 bits
    r@ 12 rshift $3ff and or        \ prep and combine imm10 bits
    r@ r@ 2 lshift xor invert dup   \ prep J1, J2 with func i=!(s^j)
    $00800000 and 6 lshift          \ mask and move J1 into position
    swap                            \ work on J2
    $00400000 and 5 lshift          \ mask and move J2 into position
    or or                           \ combine with op
    r> $01000000 and 14 rshift      \ prepare S bit
    or ,  ;                         \ combine with op and save


