/* $Revision: 1.1 $ */
#include "dba.ext"
#include "cursor.def"

/* Function:	dba_attached 

Description: 	returns the currently attached schema name

Author: 	Brian Potter
*/
int dba_attached (sch_ptr)
char **sch_ptr;
{
  char schema[RISMAX];
  int status;

  status = dba_select (DBA_C1, NP, "select schema_name from ris_schemaid");
  if (status) return (0);
  status = dba_fetch (DBA_C1, NP, schema, NP);
  dba_close_cursor (DBA_C1);
  if (status) return (0);

  *sch_ptr = schema;

  return (1);
}
