\ check tmt32 canonical values

$3793fdff $fc78ff1f $8f7011ee TMT32 trand

: tmt32-check
 1 trand tmt32-init cr
 10 0 do 5 0 do trand tmt32-generate 11 u.r loop cr loop ;
