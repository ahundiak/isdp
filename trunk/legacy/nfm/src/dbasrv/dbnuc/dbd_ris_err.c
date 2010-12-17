#include "ris.h"

#line 1 "dbd_ris_err.rc"
/* $Revision: 1.1 $ */
/* Function:  dba_ris_report_ris_error
   Author:    Tim A. Thompson
   Date:      18-APR-91
*/

int dba_ris_report_ris_error ()
{

#line 9 "dbd_ris_err.rc"

char * err;

#line 11 "dbd_ris_err.rc"


  int status;

RISint_report_error(0,&err);

#line 15 "dbd_ris_err.rc"

  status = dba_output_error (err);
  if (status) return (status);

  return (0);
}
