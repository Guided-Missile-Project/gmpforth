/* 
   vmem.h

   Copyright (c) 2011 by Daniel Kelley

   $Id:$
*/

#ifndef   _VMEM_H_
#define   _VMEM_H_

typedef int (*vmem_write_f)(unsigned int addr, unsigned int value, void *data);

int vmem(const char *file, vmem_write_f writer, void *data);

#endif /* _VMEM_H_ */
