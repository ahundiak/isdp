/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

/* Function:    dba_add_error */

int dba_add_error (message)
char *message;
{
  int (*add_error_func)();

  add_error_func = dba_inq_service (DBA_ADD_ERROR);
  if (add_error_func)
    (*add_error_func) (message);

  return (0);
}
