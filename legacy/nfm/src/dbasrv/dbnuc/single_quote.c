/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>

/* Function:	dba_single_quote */
int dba_single_quote (text)
char *text;
{
  char *char_ptr, *tic_ptr;

  char_ptr = text;
search:
  tic_ptr = strchr (char_ptr, 39);
  if (!tic_ptr) return (0);

  strcpy (tic_ptr, tic_ptr+1);
  char_ptr = tic_ptr + 1;

  goto search;
}
