/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_set_table_number_by_name */
int dba_set_table_number_by_name (schema, table, table_number)
char *schema, *table;
int table_number;
{
  int status;
  struct dba_ent *tent=0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  tent->entnum = table_number;

  return (0);
}
