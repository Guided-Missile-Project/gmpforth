        .macro  $SYS sys
        $SET    $v0, \sys
        syscall
        .endm

        /* argument order $a0 $a1 $a2 $a3 $t0 $t1 */
