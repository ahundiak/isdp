/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>
#include "dmalloc.def"

/* Function:	dba_double_quote */
int dba_double_quote (text, size)
char **text;
unsigned long *size;
{
  char *char_ptr, *tic_ptr;
  int lng;
  static unsigned long s1_size=0;
  static char *s1_ptr;

  if (!s1_size) { s1_size = 100;  s1_ptr = dba_dmalloc (s1_size, DM_STATIC); }

  char_ptr = *text;
search:
  tic_ptr = strchr (char_ptr, 39);
  if (!tic_ptr) return (0);

  lng = strlen (*text);
  if (lng + 2 > *size)
    { *size = lng + 100;  *text = dba_drealloc (*text, *size); }

  lng = strlen (tic_ptr+1);
  if (lng + 1 > s1_size)
    { s1_size = lng + 100;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }
  strcpy (s1_ptr, tic_ptr+1);

  tic_ptr[0] = 0;
  strcat (*text, "''");
  strcat (*text, s1_ptr);
  char_ptr = tic_ptr + 2;

  goto search;
}
