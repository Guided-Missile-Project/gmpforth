#
#  Makefile
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

.PHONY: all clean

BASE := ../../..

INC := -I.. -I$(BASE)/include

ASFLAGS := -aldm=kernel.lst -g $(INC) -MD=kernel.d

MFLAGS := -g $(INC)

CFLAGS := $(MFLAGS) -O2 -fomit-frame-pointer $(INC)

LDFLAGS := $(MFLAGS) -Wl,-N -Wl,-Map=forth.map -Wl,-e_start -no-pie -nostartfiles -nodefaultlibs -nostdlib -Wl,--build-id -Wl,--no-dynamic-linker

GENERATED := kernel.inc
GENERATED += syscall.inc
GENERATED += const.inc
GENERATED += *.d

OBJCOPY := objcopy
STRIP := strip

all: forth

.DELETE_ON_ERROR: # delete target if a command returns an error

forth: kernel.o start.o io.o trap.o
	$(CC) $(LDFLAGS) -o $@ $^
	$(OBJCOPY) --only-keep-debug $@ $@.debug
	$(STRIP) $@
	$(OBJCOPY) --add-gnu-debuglink=$@.debug $@

cfmakeraw.S: cfmakeraw.c
	$(CC) -c -S -O3 -o $@ $<

termios_data.S: termios_data.c
	$(CC) -c -S -O3 -o $@ $<

start.o: start.S kernel.inc
	$(CC) -c -D__ASSEMBLY__ -MMD $(MFLAGS) -o $@ $<

io.o: io.S syscall.inc
	$(CC) -c -D__ASSEMBLY__ -MMD $(MFLAGS) -o $@ $<

trap.o: trap.S kernel.inc
	$(CC) -c -D__ASSEMBLY__ -MMD $(MFLAGS) -o $@ $<

kernel.o: kernel.s mdefs.inc ../defs.inc pre.inc kernel.inc post.inc

kernel.inc:
	$(BASE)/bin/gmpfc -c -H -tx86_64 -I$(BASE) --make-dependency=$@.d,$@ --make-asm-header=const.inc src/gas/x86_64/forth.fs src/fig/cold.fs > $@

syscall.inc:
	$(BASE)/bin/syscall-arg $(BASE)/data/syscall/x86_64-linux.yaml > $@

clean:
	-rm -f forth *.o $(GENERATED) kernel.lst \
	forth.map forth.debug

-include *.d

