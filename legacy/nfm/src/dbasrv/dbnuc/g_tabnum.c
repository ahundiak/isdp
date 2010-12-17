/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_get_table_number_by_name */
int dba_get_table_number_by_name (schema, table, table_number)
char *schema, *table;
int *table_number;
{
  int status;
  struct dba_ent *tent=0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  *table_number = tent->entnum;

  return (0);
}
