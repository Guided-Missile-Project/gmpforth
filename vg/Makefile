#
#  Makefile
#
#  Copyright (c) 2014 by Daniel Kelley
#

TOOL := gfp

VGINC := /usr/include/valgrind
LIB32 := /usr/lib
LIB64 := /usr/lib64
VGLIB32 := $(LIB32)/valgrind
VGLIB64 := $(LIB64)/valgrind

CFLAGS := -I$(VGINC) -O2 -g -Wall -Wmissing-prototypes -Wshadow -Wpointer-arith -Wstrict-prototypes -Wmissing-declarations -Wno-format-zero-length -fno-strict-aliasing -fno-builtin -fomit-frame-pointer -Wno-long-long -Wno-pointer-sign -fno-stack-protector

M64CFLAGS := -DVGA_amd64=1 -DVGO_linux=1 -DVGP_amd64_linux=1 -DVGPV_amd64_linux_vanilla=1  -m64

M64LIB := -L$(VGLIB64) -lcoregrind-amd64-linux -lvex-amd64-linux -lgcc

M32CFLAGS := -DVGA_x86=1 -DVGO_linux=1 -DVGP_x86_linux=1 -DVGPV_x86_linux_vanilla=1  -m32

M32LIB := -L$(VGLIB32) -lcoregrind-x86-linux -lvex-x86-linux -lgcc

LDFLAGS := -static -nodefaultlibs -nostartfiles -u _start -Wl,-Ttext-segment=0x38000000

GOAL :=

ifeq (x86_64,$(shell uname -m))
GOAL += $(TOOL)-amd64-linux
SYSLIB := $(LIB64)
else
GOAL += $(TOOL)-x86-linux
SYSLIB := $(LIB64)
endif

all: $(GOAL)

$(TOOL)-amd64-linux: $(TOOL)_amd64_linux.o
	$(CC) -o $@ $(LDFLAGS) -m64 $< $(M64LIB)

$(TOOL)_amd64_linux.o: $(TOOL)_main.c
	$(CC) -c -o $@ $(CFLAGS) $(M64CFLAGS) $<

$(TOOL)-x86-linux: $(TOOL)_x86_linux.o
	$(CC) -o $@ $(LDFLAGS) -m32 $< $(M32LIB)

$(TOOL)_x86_linux.o: $(TOOL)_main.c
	$(CC) -c -o $@ $(CFLAGS) $(M32CFLAGS) $<

check: $(GOAL) setup
	@echo $(PWD)
	VALGRIND_LIB=$(PWD) valgrind -v --tool=$(TOOL) /bin/ls


setup:
ifeq (x86_64,$(shell uname -m))
	ln -sf $(SYSLIB)/valgrind/vgpreload_core-amd64-linux.so .
endif
	ln -sf $(SYSLIB)/valgrind/vgpreload_core-x86-linux.so .

clean:
	-rm -f $(TOOL)-amd64-linux \
		$(TOOL)-x86-linux \
		$(TOOL)_amd64_linux.o \
		$(TOOL)_x86_linux.o \
                *.so
