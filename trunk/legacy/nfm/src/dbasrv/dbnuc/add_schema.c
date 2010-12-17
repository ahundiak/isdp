/* $Revision: 1.1 $ */
#include "dba.ext"

extern struct dba_sch *dba_fsch, *dba_lsch;

/* Function:	dba_add_schema

Description:	adds the named schema, which may actually be a "schema.password"
		combination, to the schema list, if it doesn't already exist

Author:         Brian Potter
*/

int dba_add_schema (schema_name)
char *schema_name;
{
  char name[RISMAX], password[RISMAX];
  int count=0, pass;
  struct dba_sch *tsch;

  if (!schema_name) return (0);

  pass = (sscanf (schema_name, "%[^.].%s", name, password) == 2) ? 1 : 0;
  for (tsch=dba_fsch; tsch; ++count,tsch=tsch->nsch)
    if (strcmp (tsch->name, name) == 0) break;
  if (tsch) return (0);
  dba_malloc_sch (&tsch, NP);
  tsch->schema = ++count;
  strcpy (tsch->name, name);
  if (pass) strcpy (tsch->password, password);
  if (!dba_fsch) dba_fsch = tsch;
  else { dba_lsch->nsch = tsch;  tsch->psch = dba_lsch; }
  dba_lsch = tsch;
  return (0);
}
