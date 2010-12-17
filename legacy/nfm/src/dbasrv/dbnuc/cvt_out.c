/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_process_convert_output */
int dba_process_convert_output (schema, table, column, text, length)
int schema, table, column, length;
char *text;
{
  dba_inq_convert_func (1, schema, table, column, text, length);

  return (0);
}
