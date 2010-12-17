/* $Revision: 1.1 $ */
#include "dba.ext"
#include <string.h>
#include "dmalloc.def"

/* Function:	dba_build_where */
int dba_build_where (ent_ptr, got_where, fence, create_flag, s1_ptr, s1_size,
  from_report)
struct dba_ent *ent_ptr;
int *got_where, fence, create_flag, from_report;
char **s1_ptr;
unsigned long *s1_size;
{
  char *start;
  int status=0, lng, first, slng;
  struct dba_find *tfind;

  slng = strlen (*s1_ptr);

  for (first=1,tfind=ent_ptr->ffind; tfind; tfind=tfind->nfind)
    { lng = strlen (tfind->text);
    if (lng)
      { if (first)
        { if (*got_where) strcat (*s1_ptr, " and ");
        else strcat (*s1_ptr, " where ");
        strcat (*s1_ptr, "(");
        first = 0; }
      if (strlen (*s1_ptr) + lng + 100 > *s1_size)
        { *s1_size += lng + 100;  *s1_ptr = dba_drealloc (*s1_ptr, *s1_size); }
      strcat (*s1_ptr, tfind->text);
      *got_where = 1; } }

  if (!first) 
    { if (from_report) 
      { start = *s1_ptr + slng;
      dba_check_for_clause (start); }
    strcat (*s1_ptr, ")"); }

  if (fence)
    { status = dba_inq_build_fence (create_flag, got_where, ent_ptr,
      s1_ptr, s1_size, NP, 0, 0);
    if (status) return (status);
    *got_where = 1; }

  return (0);
}
/* Function:	dba_check_for_clause */
int dba_check_for_clause (in_text)
char *in_text;
{
  char *start, *cptr;
  int sub_query;

  start = strstr (in_text, " select ");
  if (!start) start = strstr (in_text, "(select ");

  if (start)
    { sub_query = 1;
    start += 8;
    for (;;++start)
      { if (!sub_query || *start == 0) break;
      if (*start == '(') ++sub_query;
      else if (*start == ')') --sub_query; } }
  else start = in_text;

  cptr = strstr (start, " order by ");
  if (cptr) *cptr = 0;
  cptr = strstr (start, " group by ");
  if (cptr) *cptr = 0;
  cptr = strstr (start, " having ");
  if (cptr) *cptr = 0;

  return (0);
}
