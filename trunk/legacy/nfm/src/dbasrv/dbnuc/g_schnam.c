/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_get_schema_name_by_number */
int dba_get_schema_name_by_number (schema, schema_name)
int schema;
char *schema_name;
{
  int status;
  struct dba_sch *tsch=0;

  status = dba_set_sch_ptr (schema, NP, &tsch, 1);
  if (status) return (status);

  strcpy (schema_name, tsch->name);

  return (0);
}
