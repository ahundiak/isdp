/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"

/* Function:	dba_set_table_alias */
int dba_set_table_alias (schema, table, alias)
char *schema, *table, *alias;
{
  int status;
  struct dba_ent *tent=0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  if (alias) {
    if (tent->alias) dba_dfree (tent->alias);
    tent->alias = dba_dstrdup (alias, DM_MEMBER);
  }
  return (0);
}
