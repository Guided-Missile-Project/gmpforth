
: (does,) ( -- )
    $0c000000                       ( jal opcode )
    $does_handler$                  ( address of does handler )
      2 rshift $3ffffff and         ( absolute address shifted and masked )
      or , 0 ( nop) , ;             ( store in dict followed by nop )
