/* $Revision: 1.1 $ */
#include "dba.ext"

#if defined RIS5
#include "ris.h"
#else
#include "sql.h"
#endif

extern char *dba_errtxt;

/* Function:	dba_sqlerr 

Description: 	gets the current RIS error message and displays it in the
		RIS error form or stderr

Author: 	Brian Potter
*/
int dba_sqlerr ()
{
  int status;

  status = dba_report_ris_error ();
  if (status) dba_printf ("%s", dba_errtxt);
  strcpy (dba_errtxt, dba_get_msg (DBA_E_RIS, "%ld", 0, 
    (long) dba_get_sqlcode(), NP));

  return (0);
}
