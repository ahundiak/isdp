/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>

/* Function:	dba_parse_string 

Description: 	parses an input text string and returns the delimited text,
		then updates the input text string pointer for subsequent calls 

Author:		Brian Potter
*/
int dba_parse_string (in_ptr, out_ptr, delimiter, skip_dup)
char **in_ptr, *out_ptr;
int delimiter, skip_dup;
{
  char *char_ptr;
  int lng;

  if (!(*in_ptr)) return (0);

  if (*(*in_ptr) == delimiter) ++(*in_ptr);
  if (skip_dup)
    while (*(*in_ptr) == delimiter) ++(*in_ptr);

  if (!(*(*in_ptr))) return (0);

  char_ptr = strchr (*in_ptr, delimiter);
  if (char_ptr)
    { lng = char_ptr - *in_ptr;
    strncpy (out_ptr, *in_ptr, lng);  out_ptr[lng] = 0; }
  else
    { lng = strlen (*in_ptr);
    strncpy (out_ptr, *in_ptr, lng);  out_ptr[lng] = 0; }
  *in_ptr += lng;

  return (1);
}
