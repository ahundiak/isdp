/* $Revision: 1.1 $ */
#include "dba.ext"

extern char dba_text[], *dba_fldval;

/* Function:	dba_add_query */
int dba_add_query (logical, schema, table, column, relop, attval)
char *logical, *schema, *table, *column, *relop, *attval;
{
  int status;
  struct dba_ent *tent;
  struct dba_att *tatt;

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  sprintf (dba_text, "%d.%s.%s", tent->schema, tent->entnam, column);
  status = dba_parse_att (dba_text, &tatt);
  if (status) return (status);

  strcpy (dba_fldval, attval);
  if (!strlen (attval)) strcpy (dba_fldval, " ");
  status = dba_add_find (logical, tatt, relop);
  if (status == 98) return (0);
  else return (status);
}
