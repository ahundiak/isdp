/* $Revision: 1.1 $ */
#include "dba.ext"
extern struct dba_sch *dba_csch;

/* Function:	dba_parse_sch

Description:    returns an schema pointer when passed a
		schema (name or number) 

Author:         Brian Potter
*/

int dba_parse_sch (schema, sch_ptr)
char *schema;
struct dba_sch **sch_ptr;
{
  int status, schnum;

  status = sscanf (schema, "%d", &schnum);
  if (status == 1)
    { if (schnum)
      { status = dba_set_sch_ptr (schnum, NP, sch_ptr, 1);
      if (status) return (status); }
    else
      *sch_ptr = dba_csch; }
  else
    { status = dba_set_sch_ptr (0, schema, sch_ptr, 1);
    if (status) return (status); }

  return (0);
}
