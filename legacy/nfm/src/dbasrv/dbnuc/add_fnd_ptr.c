/* $Revision: 1.1 $ */
#include "dba.ext"
/* Function:	dba_add_find_ptr */
int dba_add_find_ptr (ffind_ptr, lfind_ptr, find_ptr)
struct dba_find **ffind_ptr, **lfind_ptr, *find_ptr;
{
  if (*ffind_ptr)
    (*lfind_ptr)->nfind = find_ptr;
  else
    *ffind_ptr = find_ptr;
  *lfind_ptr = find_ptr;
  return (0);
}
