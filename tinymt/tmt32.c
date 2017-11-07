/*
   tmt32.c

   @author Mutsuo Saito (Hiroshima University)
   @author Makoto Matsumoto (The University of Tokyo)

   Copyright (C) 2011 Mutsuo Saito, Makoto Matsumoto,
   Hiroshima University and The University of Tokyo.
   All rights reserved.

   The 3-clause BSD License is applied to this software, see
   LICENSE.txt

   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html

   Modifications by Daniel Kelley 26.04.2014

   This is a simplified reference implementation of
   tinymt32_generate_uint32() to generate test vectors
   for the GMPForth implementation(s) of this algorithm.

*/

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

#define TINYMT32_MASK UINT32_C(0x7fffffff)

struct TINYMT32_T {
    uint32_t status[4];
    uint32_t mat1; // 4
    uint32_t mat2; // 5
    uint32_t tmat; // 6
};

typedef struct TINYMT32_T tinymt32_t;

static void tinymt32_next_state(tinymt32_t * random) {
    uint32_t x;
    uint32_t y;

    y = random->status[3];
    x = (random->status[0] & TINYMT32_MASK)
	^ random->status[1]
	^ random->status[2];
    x ^= (x << 1);
    y ^= (y >> 1) ^ x;
    random->status[0] = random->status[1];
    random->status[1] = random->status[2];
    random->status[2] = x ^ (y << 10);
    random->status[3] = y;
    random->status[1] ^= -((int32_t)(y & 1)) & random->mat1;
    random->status[2] ^= -((int32_t)(y & 1)) & random->mat2;
}

static uint32_t tinymt32_temper(tinymt32_t * random) {
    uint32_t t0, t1;
    t0 = random->status[3];
    t1 = random->status[0]
	+ (random->status[2] >> 8);
    t0 ^= t1;
    t0 ^= -((int32_t)(t1 & 1)) & random->tmat;
    return t0;
}

static void period_certification(tinymt32_t * random) {
    if ((random->status[0] & TINYMT32_MASK) == 0 &&
	random->status[1] == 0 &&
	random->status[2] == 0 &&
	random->status[3] == 0) {
	random->status[0] = 'T';
	random->status[1] = 'I';
	random->status[2] = 'N';
	random->status[3] = 'Y';
    }
}

static void tinymt32_init_state(tinymt32_t * random, int idx) {
    int idx2 = (idx - 1) & 3;
    uint32_t q = (random->status[idx2] ^ (random->status[idx2] >> 30));
    random->status[idx & 3] ^= idx + UINT32_C(1812433253) * q;
}

static void tinymt32_init(tinymt32_t * random, uint32_t seed) {
    random->status[0] = seed;
    random->status[1] = random->mat1;
    random->status[2] = random->mat2;
    random->status[3] = random->tmat;
    for (int i = 1; i < 8; i++) {
	tinymt32_init_state(random, i);
    }
    period_certification(random);
    for (int i = 0; i < 8; i++) {
	tinymt32_next_state(random);
    }
}

/**
 * This function outputs 32-bit unsigned integer from internal state.
 * @param random tinymt internal status
 * @return 32-bit unsigned integer r (0 <= r < 2^32)
 */
static uint32_t tinymt32_generate_uint32(tinymt32_t * random) {
    tinymt32_next_state(random);
    return tinymt32_temper(random);
}

/* from Check32, hardcoded for original test vector generation */
static void check32(void) {
    tinymt32_t tinymt;
    tinymt.mat1 = 0x8f7011ee;
    tinymt.mat2 = 0xfc78ff1f;
    tinymt.tmat = 0x3793fdff;
    tinymt32_init(&tinymt, 1);
    for (int i = 0; i < 10; i++) {
	for (int j = 0; j < 5; j++) {
	    printf("%10"PRIu32" ", tinymt32_generate_uint32(&tinymt));
	}
	printf("\n");
    }
}

int main(int argc, char *argv[])
{
    check32();
    return 0;
}
