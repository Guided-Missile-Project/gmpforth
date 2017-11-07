CODE ROLL
        popq    %rcx
        cmpq    $0, %rcx
        jns     2f
        /* non-standard inverse roll */
        negq    %rcx
        movq    (%rsp), %rbx
        movq    $1, %rax
1:
        movq    (%rsp,%rax,_SZ), %rdx
        dec     %rax
        movq    %rdx, (%rsp,%rax,_SZ)
        inc     %rax
        inc     %rax
        loopnz  1b
        dec     %rax
        movq    %rbx, (%rsp,%rax,_SZ)
        $NEXT
2:
        jz      4f
        /* standard roll */
        movq    %rcx, %rax
        movq    (%rsp,%rcx,_SZ), %rbx
3:
        dec     %rax
        movq    (%rsp,%rax,_SZ), %rdx
        movq    %rdx, (%rsp,%rcx,_SZ)
        loopnz  3b
        movq    %rbx, (%rsp)
4:
        $NEXT
END-CODE
