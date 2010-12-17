/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_get_column_number_by_name */
int dba_get_column_number_by_name (schema, table, column, column_number)
char *schema, *table, *column;
int *column_number;
{
  char spec[50];
  int status;
  struct dba_ent *tent=0;
  struct dba_att *tatt=0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  sprintf (spec, "%d.%d.%s", tent->schema, tent->entnum, column);
  status = dba_parse_att (spec, &tatt);
  if (status) return (status);

  *column_number = tatt->attnum;

  return (0);
}
