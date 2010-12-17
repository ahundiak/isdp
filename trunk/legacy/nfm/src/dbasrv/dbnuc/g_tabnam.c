/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_get_table_name_by_number */
int dba_get_table_name_by_number (schema, table, table_name)
char *schema, *table_name;
int table;
{
  char text[20];
  int status;
  struct dba_ent *tent=0;

  sprintf (text, "%d", table);
  status = dba_set_schent_ptr (schema, text, &tent);
  if (status) return (status);

  strcpy (table_name, tent->entnam);

  return (0);
}
