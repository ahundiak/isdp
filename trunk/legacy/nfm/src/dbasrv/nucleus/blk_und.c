/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>

/* Function:	dba_blanks_to_underbars */
int dba_blanks_to_underbars (text_ptr)
char *text_ptr;
{
  char *t, *b;

  if (!text_ptr) return (0);

  for (t=text_ptr; ;) {
    b = strchr (t, 32);
    if (!b) break;
    *b = 95;
    t = b + 1;
  }
  return (0);
}
