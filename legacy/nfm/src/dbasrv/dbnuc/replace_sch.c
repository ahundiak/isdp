/* $Revision: 1.1 $ */
#include "dba.ext"

extern struct dba_sch *dba_fsch, *dba_lsch;

/* Function:	dba_replace_schema

Description:	adds the named schema, which may actually be a "schema.password"
		combination, at the specified schema list position, replacing 
		any existing schema in that slot

Author:         Brian Potter
*/

int dba_replace_schema (sch_ptr, schema_name, position)
struct dba_sch *sch_ptr;
char *schema_name;
int position;
{
  char name[RISMAX], password[RISMAX];
  int count, pass;
  struct dba_sch *tsch;

  for (count=1,tsch=dba_fsch; tsch; ++count,tsch=tsch->nsch)
    if (count == position) break;

  if (!sch_ptr)
    { pass = (sscanf (schema_name, "%[^.].%s", name, password) == 2) ? 1 : 0;
    dba_malloc_sch (&sch_ptr, NP);
    strcpy (sch_ptr->name, name);
    if (pass) strcpy (sch_ptr->password, password); }

  sch_ptr->schema = position;

  sch_ptr->psch = tsch->psch;
  sch_ptr->nsch = tsch->nsch;
  if (tsch->psch) tsch->psch->nsch = sch_ptr;
  else dba_fsch = sch_ptr;
  if (tsch->nsch) tsch->nsch->psch = sch_ptr;
  else dba_lsch = sch_ptr;

  return (0);
}
