/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_get_schema_number_by_name */
int dba_get_schema_number_by_name (schema, schema_number)
char *schema;
int *schema_number;
{
  int status;
  struct dba_sch *tsch=0;

  status = dba_set_sch_ptr (0, schema, &tsch, 1);
  if (status) return (status);

  *schema_number = tsch->schema;

  return (0);
}
