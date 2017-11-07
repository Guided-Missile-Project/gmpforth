/* 
   stack.h

   Copyright (c) 2011 by Daniel Kelley

   $Id:$
*/

#ifndef   _STACK_H_
#define   _STACK_H_

struct stack {
  int size;
  int idx;
  unsigned int *mem;
};


int stack_alloc(struct stack *stk, int size);
void stack_free(struct stack *stk);
void stack_push(struct stack *stk, unsigned int value);
unsigned int stack_pop(struct stack *stk);
unsigned int stack_pick(struct stack *stk, unsigned int offset);
void stack_roll(struct stack *stk, int offset);
void stack_rot(struct stack *stk);
void stack_dash_rot(struct stack *stk);
void stack_swap(struct stack *stk);
unsigned int stack_tos(struct stack *stk);
unsigned int stack_nos(struct stack *stk);
unsigned int stack_depth(struct stack *stk);
void stack_set_idx(struct stack *stk, int idx);
void stack_set_tos(struct stack *stk, unsigned int value);
void stack_set_nos(struct stack *stk, unsigned int value);
void stack_reset(struct stack *stk);

#endif /* _STACK_H_ */
