   -3 parameter IO_MEM_LIMIT
   -4 parameter IO_TX_STORE
   -5 parameter IO_TX_QUESTION
   -6 parameter IO_RX_FETCH
   -7 parameter IO_RX_QUESTION
   -8 parameter IO_HALT

\ extended - unsupported by VM

   -9 parameter IO_MMAP
  -10 parameter IO_MUNMAP
  -11 parameter IO_OPEN_FILE
  -12 parameter IO_CLOSE_FIZE
  -13 parameter IO_SIZE_FILE

\ smallest negative number to consider as an error code
 -255 parameter IO_MAX_ERRORNO
\ base system exception code
-1000 parameter IO_ERRNO_EXCEPTION