\
\ Create RISC V branch-and-link to does_handler
\
\ Instruction and address fields are notated as follows:
\
\ d=imm[20]
\ c=imm[19:12]
\ b=imm[11]
\ a=imm[10:1]
\ r=rd
\ k=opcode
\
\ 33222222222211111111110000000000
\ 10987654321098765432109876543210
\ ---0---0---0---0---0---0---e---f
\ daaaaaaaaaabccccccccrrrrrkkkkkkk  - JAL instruction decoding
\ daaaaaaaaaabcccccccc000011101111  - jal ra instruction
\ ddddddddddddccccccccbaaaaaaaaaa0  - address bit sources

: (does,) ( -- )
    $000000ef                       \ jal opcode
    $does_handler$ here - >r        \ relative offset to does handler in R
    r@ 11 lshift $80000000 and or   \ imm[20]    (combine d)
    r@ 20 lshift $7fe00000 and or   \ imm[10:1]  (combine a)
    r@  9 lshift $00100000 and or   \ imm[11]    (combine b)
    r>           $000ff000 and or   \ imm[19:12] (combine c)
    , ;                             \ store in dict

