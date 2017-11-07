/* 
   vmem.c

   Copyright (c) 2011 by Daniel Kelley

   $Id:$
*/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "vmem.h"

enum comment_t {
  comment_none,         /* no comment */
  comment_cpp,          /* fully in CPP omment */
  comment_c,            /* fully in C comment */
  comment_slash,        /* first slash of C or CPP comment */
  comment_c_star        /* second star of C comment */
};

static void handle_comment_slash(enum comment_t *comment_p)
{
  switch (*comment_p) {
  case comment_none:
    *comment_p=comment_slash;
    break;
  case comment_cpp:
  case comment_c:
    /* ignore */
    break;
  case comment_slash:
    *comment_p=comment_cpp;
    break;
  default:
    assert(0); /* should not happen */
    break;
  case comment_c_star:
    *comment_p=comment_none;
    break;
  }
}

static void handle_comment_star(enum comment_t *comment_p)
{
  switch (*comment_p) {
  case comment_slash:
    *comment_p=comment_c;
    break;
  case comment_cpp:
    /* ignore */
    break;
  case comment_c:
    *comment_p=comment_c_star;
    break;
  case comment_none:
  case comment_c_star:
  default:
    assert(0); /* should not happen */
    break;
  }
}

int vmem(const char *file, vmem_write_f writer, void *data)
{
  unsigned int addr = 0;
  unsigned int value;
  enum comment_t comment = comment_none;
  int c;
  int p;
  int a;
  int rc = 0;
  char num[64];
  FILE *f;

  f = fopen(file, "r");
  if (f == NULL) {
    return -1;
  }

  p = 0;
  a = 0;
  while (!feof(f)) {
    c = fgetc(f);
    switch (c) {
    case '/':
      handle_comment_slash(&comment);
      break;
    case '*':
      handle_comment_star(&comment);
      break;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case 'a':
    case 'b':
    case 'c':
    case 'd':
    case 'e':
    case 'f':
    case 'A':
    case 'B':
    case 'C':
    case 'D':
    case 'E':
    case 'F':
      /* hex digit */
      if (comment == comment_none) {
        num[p++] = c;
      }
      break;
    case 'x':
    case 'X':
      if (comment == comment_none) {
        /* treat uninit as 0 */
        num[p++] = '0';
      }
      break;
    case '@':
      if (comment == comment_none) {
        a = 1;
      }
      break;
    case '\n':
      if (comment == comment_cpp) {
        comment = comment_none;
        break;
      }
      /* otherwise, fall through */
    case '\t':
    case ' ':
      /* space */
      if (comment == comment_none) {
        if (p > 0) {
          num[p++] = 0;
          value = strtoul(num, NULL, 16);
          p = 0;
          if (a) {
            addr = value;
            a = 0;
          } else {
            rc = writer(addr, value, data);
            if (rc) {
              goto done;
            }
            addr++;
          }
        }
      }
      break;
    }
  }
 done:
  fclose(f);

  return rc;
}
