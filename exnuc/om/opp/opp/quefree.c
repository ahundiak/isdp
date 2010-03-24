#include "carriers.h"
#include "quefree.h"
#include "oppmalloc.h"

#define placebo

static carrier_ptr the_queue = 0;

void que_free(t)
identifier_ptr t;
 {
#ifdef placebo
  carrier_ptr c;

  c = (carrier_ptr)malloc(sizeof(*c));
  c->cargo = t;
  c->next = the_queue;
  the_queue = c;
#endif
 }

void free_que ()
 {
#ifdef placebo
  carrier_ptr c,b;

  c = the_queue;
  the_queue = 0;
  while (c)
   {
    b = c->next;
    free (c->cargo);
    free (c);
    c = b;
   }
#endif
 }
