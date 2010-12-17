/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_errtxt;
extern struct dba_att *dba_catt;

/* Function:	dba_get_current_column

Description:	returns the schema, table, and column name of the 
		last column accessed on any dba menu by a key-in or poke

Author:		Brian Potter */

int dba_get_current_column (schema, table, column)
char *schema, *table, *column;
{
  int status;
  struct dba_sch *tsch;

  dba_set_catt ();

  if (!dba_catt)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_CURRENT_COLUMN, NP,0,NP,NP));
    return (99); }

  status = dba_set_sch_ptr (dba_catt->schema, NP, &tsch, 1);
  if (status) return (status);

  strcpy (schema, tsch->name);
  strcpy (table, dba_catt->entnam);
  strcpy (column, dba_catt->attnam);

  return (0);
}
