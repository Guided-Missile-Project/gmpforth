#
#  Makefile
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

CFLAGS := -std=gnu99 -g -Wall -I../include
LDFLAGS := -g

all: cvm

cvm: cvm.o stack.o vmem.o

cvm.c: stack.h vmem.h

stack.c: stack.h

vmem.c: vmem.h

clean:
	-rm -f cvm *.o
