/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>
#include "dmalloc.def"

/* Function:	dba_tic_to_code */
char *dba_tic_to_code (char_ptr)
char *char_ptr;
{
  char *tic_ptr, *begin;
  int cnt, tics=1;
  static char *s1_ptr, *s2_ptr;
  static unsigned long s1_size=0, s2_size=0;

  if (!char_ptr) return ("");

  tic_ptr = strchr (char_ptr, 39);
  if (!tic_ptr) return (char_ptr);

/* count tics */

  for (begin=char_ptr,tics=0;;) {
    tic_ptr = strchr (begin, 39);
    if (tic_ptr)
      begin = tic_ptr + 1;
    else
      break;
    ++tics;
  }
  
  if (!s1_size) {
    s1_size = 200;
    s1_ptr = dba_dmalloc (s1_size, DM_STATIC);
    s2_size = 200;
    s2_ptr = dba_dmalloc (s2_size, DM_STATIC);
  }
  cnt = strlen (char_ptr);
  if (cnt + (tics * 2) + 1 > s1_size) {
    s1_size = cnt + (tics * 2) + 1;
    s1_ptr = dba_drealloc (s1_ptr, s1_size);
  }
  strcpy (s1_ptr, char_ptr);

search:
  tic_ptr = strchr (s1_ptr, 39);
  if (!tic_ptr) return (s1_ptr);

/* no longer needed because s1_ptr is big enough already.  6/12/94 blp
  cnt = strlen (s1_ptr);
  if (cnt + 2 > s1_size)
    { s1_size = cnt + 100;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }
*/
  cnt = strlen (tic_ptr);
  if (cnt > s2_size) {
    s2_size = cnt;
    s2_ptr = dba_drealloc (s2_ptr, s2_size);
  }
  strcpy (s2_ptr, tic_ptr+1);

  tic_ptr[0] = 92;
  tic_ptr[1] = '3';
  tic_ptr[2] = '9';  
  strcpy (tic_ptr+3, s2_ptr);

  goto search;
}
