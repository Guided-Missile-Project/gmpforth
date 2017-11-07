\ CALL compiler for does>
\ 32 bit big endian architecture
: CALL ( a -- ) $80000000 or , ;
