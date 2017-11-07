#
#  Makefile
#
#  Copyright (c) 2014 by Daniel Kelley
#

CFLAGS := -g -Wall -std=c99

PROGS := tmt32

all: $(PROGS)

clean:
	-rm -f $(PROGS) tmt32.out.txt

check32: tmt32.out.txt
	cmp tmt32.out.txt check32.out.uint32_t.txt

tmt32.out.txt: tmt32
	./tmt32 > $@
