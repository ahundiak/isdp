/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_flush_codelist

Description: 	causes DBA to rebuild code definition, useful if
		code lists have been added or modified outside of DBA

Author: 	Brian Potter
*/
int dba_flush_codelist (schema, table, column)
char *schema, *table, *column;
{
  int status;
  struct dba_ent *tent;
  struct dba_code_list *ccl;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  status = dba_find_codelist (tent->schema, tent->entnam, column, &ccl);
  if (status) return (99);

  ccl->built = 0;

  return (0);
}
