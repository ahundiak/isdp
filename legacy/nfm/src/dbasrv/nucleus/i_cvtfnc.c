/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

/* Function:	dba_inq_convert_func */
int dba_inq_convert_func (option, schema, table, column, text, length)
int option, schema, table, column, length;
char *text;
{
  int (*func)();

  func = dba_inq_service (DBA_CONVERT_COLUMN);
  if (func) 
    (*func) (option, schema, table, column, text, length);
  else
    dba_add_error (dba_get_msg (DBA_E_NO_SCRIPT, NP,0,NP,NP));

  return (0);
}
