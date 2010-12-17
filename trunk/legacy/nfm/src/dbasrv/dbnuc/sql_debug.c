/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_sql_debug */
/* ARGSUSED */
int dba_sql_debug (args)
char *args;
{
  int status;

  dba_lower (args);
  status = RISint_process_debug_no_output (args);

  return (1);
}
