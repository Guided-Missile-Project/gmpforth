CODE (io)
        .globl  iotbl
        .globl  _iobuf
        .globl  _ioarg
        .globl  _END_DICT
        % mark global so they easily show up in disassembly
        .globl ret_false
        .globl ret_true
        .globl io_size_file
        .globl io_close_file
        .globl io_open_file
        .globl io_munmap
        .globl io_mmap
        .globl hlt
        .globl rxfetch
        .globl txstore
        .globl io_init

__iobuf GREG    _iobuf          % GASCOMPILER:NOINDENT
__ioini GREG    io_init         % GASCOMPILER:NOINDENT
__edict GREG    _END_DICT       % GASCOMPILER:NOINDENT

        .set _HAS_PAREN_IO, 1

        .set _RDH, 3            % read handle
        .set _WRH, 4            % write handle

        $BLOCK
        % check (io) opcode
        $TRANSFER
        pbn     p1, 1f
        jmp     ret_false       % generalized syscall interface not supported
1:
        $BLOCK
        $SET    t2, 16
        neg     t2, t2
        cmp     t1, p1, t2
        $TRANSFER
        pbnn    t1, 1f
        jmp     ret_false       % local IO call out of range
1:
        $BLOCK
        lda     t1, iotbl       % get iotbl addr - see start.inc
        sl      p1, p1, 3
        ldo     t1, t1, p1
        $TRANSFER
        go      p1, t1          % branch to handler

        % txstore 
txstore:
        $BLOCK
        pbz     __ioini, 1f
        go      w, __ioini
1:
        $PNOS   p1
        stbu    p1, __iobuf     % save char in iobuf
        lda     $255, _ioarg    % write via MMIX system call
        trap    0, Fwrite, _WRH % ignore IO result
        $PDIS   2
        $PTOS   p1
        $NEXT

        % ret_true 
ret_true:
        $BLOCK
        $SET    p1, 1
        neg     p1, p1
        $NEXT

        % ret_false
ret_false:
        $BLOCK
        $SET    p1, 0
        $NEXT

        % rx_fetch 
rxfetch:
        $BLOCK
        pbz     __ioini, 1f
        go      w, __ioini
1:
        lda     $255, _ioarg    % read via MMIX system call
        trap    0, Fread, _RDH  % read character
        pbnn    $255, 2f
        $SET    p1, $255
        jmp     3f
2:
        ldbu    p1, __iobuf
3:
        $NEXT

        % memlimit
memlimit:
        $BLOCK
        $MOV    p1, __edict
        $NEXT

io_mmap:
        $BLOCK
        % io_mmap ( fd len -- addr' ior ) 
        $SET    p1, 0
        $NEXT

io_munmap:
        $BLOCK
        % io_munmap ( addr len -- ior ) 
        $SET    p1, 0
        $NEXT

io_open_file:
        $BLOCK
        % io_open_file  ( cstr flags -- ior ) 
        $SET    p1, 0
        $NEXT

io_close_file:
        $BLOCK
        % io_close_file  ( fd -- ior ) 
        $SET    p1, 0
        $NEXT

io_size_file:
        $BLOCK
        % io_size_file  ( fd -- ior ) 
        $SET    p1, 0
        $NEXT

hlt:
        $TRANSFER
        go     p1, _exit

io_init:
        lda    $255, io_ina
        trap   0, Fopen, _RDH
        bn     $255, hlt
        lda    $255, io_outa
        trap   0, Fopen, _WRH
        bn     $255, hlt
        xor    __ioini, __ioini, __ioini % clear __ioini for one-time init
        go     w, w

        .data
        % input device
        $ALIGN
io_inf:
        .asciz "/dev/stdin"
        % input handle
        $ALIGN
io_ina:
        .quad   io_inf
        .quad   BinaryRead
        % output device
        $ALIGN
io_outf:
        .asciz "/dev/stdout"
        % output handle
        $ALIGN
io_outa:
        .quad   io_outf
        .quad   BinaryWrite

        % io buffer
        $ALIGN
_iobuf:
        .byte   0
        $ALIGN
_ioarg:
        .quad   _iobuf, 1

iotbl_end:
        .quad   ret_false       % -16 unimplemented  
        .quad   ret_false       % -15 unimplemented  
        .quad   ret_false       % -14 unimplemented  
        .quad   io_size_file    % -13 IO_SIZE_FILE   
        .quad   io_close_file   % -12 IO_CLOSE_FIZE  
        .quad   io_open_file    % -11 IO_OPEN_FILE   
        .quad   io_munmap       % -10 IO_MUNMAP      
        .quad   io_mmap         % -9  IO_MMAP        
        .quad   hlt             % -8  IO_HALT        
        .quad   ret_true        % -7  IO_RX_QUESTION 
        .quad   rxfetch         % -6  IO_RX_FETCH    
        .quad   ret_true        % -5  IO_TX_QUESTION 
        .quad   txstore         % -4  IO_TX_STORE    
        .quad   memlimit        % -3  IO_MEM_LIMIT
        .quad   ret_false       % -2  unimplemented
        .quad   ret_false       % -1  unimplemented
iotbl:

END-CODE
