#include        "asm/unistd.h"
#include        "asm/ioctls.h"
#include        "syscall-linux.inc"
#include        "mdefs.inc"
#include        "defs.inc"
#include        "../x86_64/termios.inc"

        .globl  _io
        .globl  _exit
        .globl  aelist
        .globl  _END_DICT
        .set    nr_sysargs, linux_sysargs_end - linux_sysargs

        .macro $TRACE point
        $TRACE_LABEL io, \point
        .endm

        .text
_io:
        $BLOCK
        /* save %esi,%edi which may be destroyed by system calls on
           return stack */
        subl    $_SZ, %ebp
        movl    %esi, (%ebp)
        subl    $_SZ, %ebp
        movl    %edi, (%ebp)
        movl    (%esp), %eax            /* get IO code*/
        cmpl    $0, %eax
        $TRANSFER
        jns     syscall                 /* >=0 is syscall */
        $BLOCK
        cmpl    $-16, %eax              /* <-16 is hlt */
        $TRANSFER
        jb      hlt
__io:
        $BLOCK
        mov     iotbl(,%eax,_SZ), %edx  /* lookup in iotbl */
        $TRANSFER
        jmp     *%edx

        /* txstore */
txstore:
        $BLOCK
        cmpl    $0, needraw
        $TRANSFER
        jne     1f
        call    setraw
1:
        $BLOCK
        addl    $_SZ, %esp /* pop (io) opcode */
        $SYS3   __NR_write, $1, %esp, $1
        cmpl    $1, %eax
        $TRANSFER
        jne     hlt
        $BLOCK
        addl    $_SZ, %esp /* pop character */
        jmp     io_next

        /* ret_true */
ret_true:
        $BLOCK
        movl    $-1, (%esp)
        jmp     io_next

        /* ret_false */
ret_false:
        $BLOCK
        movl    $0, (%esp)
        jmp     io_next

        /* rx_fetch */
rxfetch:
        $BLOCK
        cmpl    $0, needraw
        $TRANSFER
        jne     1f
        call    setraw
1:
        $BLOCK
        /* IO req on stack will be overwritten by read */
        movl    $0, (%esp)
        $SYS3   __NR_read, $0, %esp, $1
        cmpl    $1, %eax
        $TRANSFER
        je      2f
        /* make error or eof look like cr to force accept to complete */
        $BLOCK
        movl    $13, (%esp)
2:
        $BLOCK
        jmp     io_next

        /* memlimit */
memlimit:
        $BLOCK
        movl    $_END_DICT, (%esp)
        jmp     io_next

io_mmap:
        $BLOCK
        /* io_mmap ( fd len -- addr' ior ) */
        addl    $_SZ, %esp /* pop (io) opcode */
        popl    %ebx            /* len */
        popl    %eax            /* fd */
        pushl   $0              /* addr */
        pushl   %ebx            /* len */
        cmpl    $0, %eax
        $TRANSFER
        jns     1f
        /* anonymous memory mapping */
        pushl   $7              /* prot */
        pushl   $0x22           /* flags */
        $TRANSFER
        jmp 2f
1:
        $BLOCK
        /* read-only file mapping */
        pushl   $5              /* prot */
        pushl   $0x02           /* flags */
2:
        $BLOCK
        pushl   %eax            /* fd */
        pushl   $0              /* addr */
        movl    $__NR_mmap2, %eax
        $TRANSFER
        jmp     syscall_direct

io_munmap:
        $BLOCK
        /* io_munmap ( addr len -- ior ) */
        addl    $_SZ, %esp /* pop (io) opcode */
        movl    $__NR_munmap, %eax
        $TRANSFER
        jmp     syscall_direct

io_open_file:
        $BLOCK
        /* io_open_file  ( cstr flags -- ior ) */
        movl    $0, (%esp) /* mode */
        movl    $__NR_open, %eax
        $TRANSFER
        jmp     syscall_direct

io_close_file:
        $BLOCK
        /* io_close_file  ( fd -- ior ) */
        addl    $_SZ, %esp /* pop (io) opcode */
        movl    $__NR_close, %eax
        $TRANSFER
        jmp     syscall_direct

io_size_file:
        $BLOCK
        /* io_size_file  ( fd -- ior ) */
        addl    $_SZ, %esp /* pop (io) opcode */
        movl    $__NR_lseek, %eax
        popl    %ebx
        movl    $0, %ecx
        movl    $2, %edx /* seek to end */
        int     $0x80
        pushl   %eax     /* save offset, which is the length of the file */
        movl    $__NR_lseek, %eax
        movl    $0, %edx /* seek to beginning */
        int     $0x80
        jmp     io_next

syscall:
        $BLOCK
        addl    $_SZ, %esp /* pop (io) opcode */
        cmpl    $nr_sysargs, %eax
        $TRANSFER
        jge     syscall_u
syscall_direct:
        $BLOCK
        movzbl  linux_sysargs(%eax), %ebx
        mov     iotbl(,%ebx,_SZ), %edx    /* lookup in iotbl */
        $TRANSFER
        jmp     *%edx

syscall_u:
        $BLOCK
        /* undefined syscall */
        movl    $-22, %eax
        $TRANSFER
        jmp     syscall_done

syscall_6:
        $BLOCK
        /* 6 argument syscall

           Still a little messy because it uses %ebp, but 6 arg
           syscalls are relatively rare, so this doesn't seem worth
           optimizing.
        */
        xchg    %ebp, (%esp)
        xchg    %edi, _SZ(%esp)
        xchg    %esi, _SZ*2(%esp)
        movl    _SZ*3(%esp), %edx
        movl    _SZ*4(%esp), %ecx
        movl    _SZ*5(%esp), %ebx
        int     $0x80
        popl    %ebp
        popl    %edi
        popl    %esi
        addl    $_SZ*3, %esp
        $TRANSFER
        jmp     syscall_done

syscall_5:
        $BLOCK
        /* 5 argument syscall */
        popl    %edi
syscall_4:
        $BLOCK
        /* 4 argument syscall */
        popl    %esi
syscall_3:
        $BLOCK
        /* 3 argument syscall */
        popl    %edx
syscall_2:
        $BLOCK
        /* 2 argument syscall */
        popl    %ecx
syscall_1:
        $BLOCK
        /* 1 argument syscall */
        popl    %ebx
syscall_0:
        $BLOCK
        /* 0 argument syscall */
        int     $0x80
syscall_done:
        $BLOCK
        pushl   %eax
io_next:
        $BLOCK
        /* restore %esi,%edi from return stack */
        movl    (%ebp), %edi
        addl    $_SZ, %ebp
        movl    (%ebp), %esi
        addl    $_SZ, %ebp
        $NEXT

hlt:
        $TRANSFER
        jmp     _exit

setraw:
        $BLOCK
        /* get current terminal state */
        $SYS3   __NR_ioctl, $0, $TCGETS, $termios_cooked

        /* if not a tty, then nevermind */
        cmpl    $0, %eax
        $TRANSFER
        jne     1f

        /* get current terminal state, and set raw */
        $SYS3   __NR_ioctl, $0, $TCGETS, $termios_raw
        push    $termios_raw
        call    cfmakeraw
        addl    $4, %esp
        $SYS3   __NR_ioctl, $0, $TCSETS, $termios_raw
        incl    needraw

        /* register setcooked atexit record */
        movl    aelist, %eax
        movl    %eax, ioatexit
        movl    $ioatexit, %eax
        movl    %eax, aelist
1:
        $TRANSFER
        ret

        /* put terminal back to cooked mode, and return the
           addr of the next atexit record */
setcooked:
        $BLOCK
        $SYS3   __NR_ioctl, $0, $TCSETS, $termios_cooked
        movl    ioatexit, %eax
        $TRANSFER
        ret

        .set    c_iflag, ~(IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK|ISTRIP|\
                           INLCR|IGNCR|ICRNL|IUCLC|IXON|IXANY|IXOFF|IMAXBEL)
        .set    c_oflag, ~OPOST
        .set    c_lflag, ~(ICANON|ECHO|ECHONL|ISIG|IEXTEN|XCASE)
        .set    c_cflaga, ~(CSIZE|PARENB)
        .set    c_cflago, CS8;

cfmakeraw:
        movl    4(%esp), %eax
        andl    $c_iflag,   (%eax)      /* c_iflag */
        andl    $c_oflag,  4(%eax)      /* c_oflag */
        andl    $c_cflaga, 8(%eax)      /* c_cflag */
        orl     $c_cflago, 8(%eax)
        andl    $c_lflag, 12(%eax)      /* c_lflag */
        movb    $0, 22(%eax)
        movb    $1, 23(%eax)
        ret

        .data

        /* atexit record: function, link */
ioatexit:
        .long   0
ioatexitf:
        .long   setcooked
iotbl_end:
        .long   ret_false       /* -16 unimplemented  */
        .long   ret_false       /* -15 unimplemented  */
        .long   ret_false       /* -14 unimplemented  */
        .long   io_size_file    /* -13 IO_SIZE_FILE   */
        .long   io_close_file   /* -12 IO_CLOSE_FIZE  */
        .long   io_open_file    /* -11 IO_OPEN_FILE   */
        .long   io_munmap       /* -10 IO_MUNMAP      */
        .long   io_mmap         /* -9  IO_MMAP        */
        .long   hlt             /* -8  IO_HALT        */
        .long   ret_true        /* -7  IO_RX_QUESTION */
        .long   rxfetch         /* -6  IO_RX_FETCH    */
        .long   ret_true        /* -5  IO_TX_QUESTION */
        .long   txstore         /* -4  IO_TX_STORE    */
        .long   memlimit        /* -3  IO_MEM_LIMIT   */
        .long   ret_false       /* -2  unimplemented  */
        .long   ret_false       /* -1  unimplemented  */
iotbl:
        .long   syscall_0       /* 0 argument syscall */
        .long   syscall_1       /* 1 argument syscall */
        .long   syscall_2       /* 2 argument syscall */
        .long   syscall_3       /* 3 argument syscall */
        .long   syscall_4       /* 4 argument syscall */
        .long   syscall_5       /* 5 argument syscall */
        .long   syscall_6       /* 6 argument syscall */
        .long   syscall_u       /* undefined syscall */
        .include "syscall.inc"
        .bss
        .balign 32
termios_raw:
        .space 60
        .balign 32
termios_cooked:
        .space 60
needraw:
        .space  _SZ
