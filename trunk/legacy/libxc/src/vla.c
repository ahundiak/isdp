#define VLA_C
#include "vla.h"

unsigned int _vla;

void _vladim (ary, sz)

vla(char)   *ary;
unsigned int sz;
{
  unsigned int dim = (_vla + ary->incr) / ary->incr * ary->incr;

  if (ary->dim = dim)
    ary->body = (ary->body ? realloc (ary->body, dim*sz) : malloc (dim*sz));
  else {
    if (ary->body) free (ary->body);
    ary->body = 0;
  }
}
