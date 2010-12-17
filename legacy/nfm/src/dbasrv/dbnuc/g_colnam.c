/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_get_column_name_by_number */
int dba_get_column_name_by_number (schema, table, column, column_name)
char *schema, *table, *column_name;
int column;
{
  char spec[50];
  int status;
  struct dba_ent *tent=0;
  struct dba_att *tatt=0;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  sprintf (spec, "%d.%d.%d", tent->schema, tent->entnum, column);
  status = dba_parse_att (spec, &tatt);
  if (status) return (status);

  strcpy (column_name, tatt->attnam);

  return (0);
}
