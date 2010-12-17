/* $Revision: 1.1 $ */
#include "dba.ext"

extern struct dba_reltemp *dba_f_reltemp;

/* Function:	dba_check_relations */
int dba_check_relations (template, from_schema, from_table, to_schema, to_table)
char *template, *from_table, *to_table;
int from_schema, to_schema;
{
  int from_hit=0, to_hit=0;
  struct dba_reltemp *reltemp;
  struct dba_reltab *reltab;

  for (reltemp=dba_f_reltemp; reltemp; reltemp=reltemp->n_reltemp)
    if (strcmp (template, reltemp->name) == 0) break;
  if (!reltemp) return (0);
  
  for (reltab=reltemp->f_reltab; reltab; reltab=reltab->n_reltab) {
    if (from_schema == reltab->schema
        && strcmp (from_table, reltab->table) == 0)
      from_hit = 1;
    if (to_schema == reltab->schema
        && strcmp (to_table, reltab->table) == 0)
      to_hit = 1;
    if (from_hit && to_hit) return (1);
  }
  return (0);
}
