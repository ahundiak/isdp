/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:    dba_output_error */
int dba_output_error (message)
char *message;
{
  dba_init_error ();
  dba_add_error (message);

  return (0);
}
