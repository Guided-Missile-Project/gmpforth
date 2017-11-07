\ CALL compiler for does>
\ 32 bit little endian architecture
: CALL ( a -- ) 8 lshift $80 or , ;
