/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

/* Function:	dba_add_to_table_list 

Description: 	adds a table to schema's list

Author: 	Brian Potter
*/
int dba_add_to_table_list (schema, table)
char *schema, *table;
{
  char entnam[33];
  int status, entnum=0;
  struct dba_sch *tsch;
  struct dba_ent *tent;

  status = dba_set_sch_ptr (0, schema, &tsch, 1);
  if (status) return (status);

  strcpy (entnam, table);
  dba_lower (entnam);

  for (tent=tsch->fent; tent; tent=tent->nent)
    { if (tent->entnum > entnum) entnum = tent->entnum;
    if (strcmp (entnam, tent->entnam) == 0) break; }

  if (!tent) 
    { dba_malloc_ent (&tent, NP);
    dba_add_ent_ptr (&tsch->fent, &tsch->lent, tent, NP);
    tent->schema = tsch->schema;
    tent->entnum = entnum + 1;
    strcpy (tent->entnam, entnam);
    tent->alias = (char *) dba_dstrdup (entnam, DM_MEMBER); }

  tent->not_listed = 0;

  return (0);
}
