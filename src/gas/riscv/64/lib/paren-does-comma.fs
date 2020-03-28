
: (does,) ( -- )
    $0c000000                       ( jal opcode )
    $does_handler$                  ( address of does handler )
      2 rshift $3ffffff and         ( absolute address shifted and masked )
      or 32 lshift , ;              ( shift up and store - nop all 0s: nice! )
