/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>
#include "dmalloc.def"

/* Function:	dba_parse_tics */
char *dba_parse_tics (char_ptr)
char **char_ptr;
{
  static char *s1_ptr, *text_ptr;
  static int jj;
  static unsigned long s1_size=0;

  if (!s1_size) { s1_size = 500;  s1_ptr = dba_dmalloc (s1_size, DM_STATIC); }
  text_ptr = strchr (*char_ptr, 39);
  if (!text_ptr) { s1_ptr[0] = 0;  text_ptr = s1_ptr;  return (text_ptr); }
  for (++text_ptr, jj=0; *text_ptr != 39; ++text_ptr, ++jj)
    { if (jj == s1_size)
      { s1_size += 500;  s1_ptr = dba_drealloc (s1_ptr, s1_size); }
    s1_ptr[jj] = *text_ptr; }
  s1_ptr[jj] = 0;  *char_ptr = text_ptr + 1;  text_ptr = s1_ptr;
  return (text_ptr);
}
