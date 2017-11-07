        .macro  $SYS sys
        $SET    x8, \sys
        svc     0       /* linux trap */
        .endm

        .macro  $SYS1 sys, p1
        $SET    x0, \p1
        $SYS    \sys
        .endm

        .macro  $SYS2 sys, p1, p2
        $SET    x1, \p2
        $SYS1   \sys, \p1
        .endm

        .macro  $SYS3 sys, p1, p2, p3
        $SET    x2, \p3
        $SYS2   \sys, \p1, \p2
        .endm

        .macro  $SYS4 sys, p1, p2, p3, p4
        $SET    x3, \p4
        $SYS3   \sys, \p1, \p2, \p3
        .endm

        .macro  $SYS5 sys, p1, p2, p3, p4, p5
        $SET    x4, \p5
        $SYS4   \sys, \p1, \p2, \p3, \p4
        .endm

        .macro  $SYS6 sys, p1, p2, p3, p4, p5, p6
        $SET    x5, \p6
        $SYS5   \sys, \p1, \p2, \p3, \p4, \p5
        .endm

        .macro  $SYS7 sys, p1, p2, p3, p4, p5, p6, p7
        $SET    x6, \p6
        $SYS6   \sys, \p1, \p2, \p3, \p4, \p5, \p6
        .endm


