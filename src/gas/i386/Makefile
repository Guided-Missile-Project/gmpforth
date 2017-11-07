#
#  Makefile
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

.PHONY: all clean

BASE := ../../..

VPATH := $(BASE)/lib/posix

INC := -I.. -I$(BASE)/include

ASFLAGS := --32 -aldm=kernel.lst -g $(INC) -MD=kernel.d

MFLAGS := -m32 -g $(INC)

CFLAGS := $(MFLAGS) -O2 -fomit-frame-pointer $(INC)

LDFLAGS := $(MFLAGS) -Wl,-N -Wl,-Map=forth.map -Wl,-e_start -nostartfiles -nodefaultlibs -nostdlib

GENERATED := kernel.inc
GENERATED += syscall.inc
GENERATED += const.inc
GENERATED += *.d

all: forth

.DELETE_ON_ERROR: # delete target if a command returns an error

forth: kernel.o start.o io.o trap.o
	$(CC) $(LDFLAGS) -o $@ $^

cfmakeraw.S: cfmakeraw.c
	$(CC) -m32 -c -S -O3 -o $@ $<

termios_data.S: termios_data.c
	$(CC) -m32 -c -S -O3 -o $@ $<

start.o: start.S kernel.inc
	$(CC) -c -D__ASSEMBLY__ -MMD $(MFLAGS) -o $@ $<

io.o: io.S syscall.inc
	$(CC) -c -D__ASSEMBLY__ -MMD $(MFLAGS) -o $@ $<

trap.o: trap.S kernel.inc
	$(CC) -c -D__ASSEMBLY__ -MMD $(MFLAGS) -o $@ $<

kernel.o: kernel.s mdefs.inc ../defs.inc pre.inc kernel.inc post.inc

kernel.inc:
	$(BASE)/bin/gmpfc -c -H -tx86 -I$(BASE) --make-dependency=$@.d,$@ --make-asm-header=const.inc src/gas/i386/forth.fs src/fig/cold.fs > $@

syscall.inc:
	$(BASE)/bin/syscall-arg $(BASE)/data/syscall/i386-linux.yaml > $@

clean:
	-rm -f forth *.o $(GENERATED) kernel.lst forth.map

-include *.d
