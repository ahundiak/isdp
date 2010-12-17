/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_init_table_query */
int dba_init_table_query (schema, table)
char *schema, *table;
{
  int status;
  struct dba_ent *tent;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  dba_free_find (tent);

  return (0);
}
