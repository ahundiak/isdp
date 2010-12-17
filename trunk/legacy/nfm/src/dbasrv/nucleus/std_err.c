/* $Revision: 1.1 $ */
#include "dba.ext"
extern char *dba_error_log;

/* Function:	dba_stderr_add_error */
int dba_stderr_add_error (message)
char *message;
{
  static FILE *err_file=0;

  if (dba_error_log && strlen (dba_error_log))
    { if (!err_file) err_file = fopen (dba_error_log, "w");
    if (err_file)
      { fprintf (err_file, "%s\n", message);  fflush (err_file); }
    return (0); }

  dba_printf ("%s\n", message);

  return (0); 
}
