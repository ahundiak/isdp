/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>

/* Function:	dba_parse_var 

Description: 	returns the text delimited by single quotes in 
		the specified string

Author: 	Brian Potter
*/
int dba_parse_var (in_ptr, out_ptr, out_lng)
char **in_ptr, **out_ptr;
unsigned long *out_lng;
{
  static char *text_ptr;
  static int count;

  text_ptr = strchr (*in_ptr, 39);
  if (!text_ptr) {
    if (*out_ptr) (*out_ptr)[0] = 0;
    return (0);
  }
  for (++text_ptr, count=0; *text_ptr != 39; ++text_ptr, ++count) {
    if (count == *out_lng) {
      *out_lng += 100;
      *out_ptr = dba_drealloc (*out_ptr, *out_lng);
    }
    (*out_ptr)[count] = *text_ptr;
  }
  if (count) {
    if (count == *out_lng) {
      *out_lng += 100;
      *out_ptr = dba_drealloc (*out_ptr, *out_lng);
    }
    (*out_ptr)[count] = 0;
  }
  *in_ptr = text_ptr + 1;

  return (0);
}
