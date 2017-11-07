/* 
   stack.c

   Copyright (c) 2011 by Daniel Kelley

   $Id:$
*/

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "stack.h"

int stack_alloc(struct stack *stk, int size)
{
  stk->mem = calloc(size, sizeof(stk->mem[0]));
  stk->size = size;
  stk->idx = 0;

  return (stk->mem == NULL) ? -1 : 0;
}

void stack_free(struct stack *stk)
{
  free(stk->mem);
  stk->mem = NULL;
  stk->idx = 0;
  stk->size = 0;
}

void stack_push(struct stack *stk, unsigned int value)
{
  assert(stk->idx < stk->size);
  stk->mem[stk->idx] = value;
  stk->idx++;
}

unsigned int stack_pop(struct stack *stk)
{
  assert(stk->idx > 0);
  stk->idx--;
  return stk->mem[stk->idx];
}

unsigned int stack_pick(struct stack *stk, unsigned int offset)
{
  assert(stk->idx > 0);
  assert(offset < stk->size);
  return stk->mem[stk->idx - offset - 1];
}

void stack_roll(struct stack *stk, int n)
{
  unsigned int tmp;
  int i;

  if (n > 0) {
    tmp = stk->mem[stk->idx-n-1];
    for (i=stk->idx-n; i<stk->idx; i++) {
      stk->mem[i-1] = stk->mem[i];
    }
    stack_set_tos(stk, tmp);
  } else if (n < 0) {
    tmp = stk->mem[stk->idx-1];
    for (i=stk->idx-2; i>stk->idx+n-2; i--) {
      stk->mem[i+1] = stk->mem[i];
    }
    stk->mem[stk->idx+n-1] = tmp;
  }
}

void stack_rot(struct stack *stk)
{
  stack_roll(stk, 2);
}

void stack_dash_rot(struct stack *stk)
{
  stack_roll(stk, -2);
}

void stack_swap(struct stack *stk)
{
  stack_roll(stk, 1);
}

unsigned int stack_tos(struct stack *stk)
{
  return stk->mem[stk->idx - 1];
}

unsigned int stack_nos(struct stack *stk)
{
  return stk->mem[stk->idx - 2];
}

unsigned int stack_depth(struct stack *stk)
{
  return stk->idx;
}

void stack_set_idx(struct stack *stk, int idx)
{
  stk->idx = idx;
}

void stack_set_tos(struct stack *stk, unsigned int value)
{
  stk->mem[stk->idx - 1] = value;
}

void stack_set_nos(struct stack *stk, unsigned int value)
{
  stk->mem[stk->idx - 2] = value;
}

void stack_reset(struct stack *stk)
{
  stack_set_idx(stk, 0);
}

