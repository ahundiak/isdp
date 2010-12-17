/* $Revision: 1.1 $ */
#include "dba.ext"

extern int dba_error_lines;

/* Function:	dba_init_error */
int dba_init_error ()
{
  dba_error_lines = 0;

  return (0);
}
