/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_delete_from_table_list 

Description: 	deletes a table from schema's list

Author: 	Brian Potter
*/
int dba_delete_from_table_list (schema, table)
char *schema, *table;
{
  int status;
  struct dba_ent *tent;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  tent->not_listed = 1;

  return (0);
}
