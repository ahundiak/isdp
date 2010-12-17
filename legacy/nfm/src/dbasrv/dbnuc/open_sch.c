/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

extern char *dba_errtxt;

/* Function:	dba_open_schema 

Description: 	opens the specified RIS schema

Author: 	Brian Potter
*/
int dba_open_schema (sch_ptr, msg)
struct dba_sch *sch_ptr;
int msg;
{
  char sqltxt[100];
  int status;
  int (*func)();

  if (sch_ptr->open) return (0);

  if (msg)
    { func = dba_inq_service (DBA_PRINT_MSG);
    if (func)
      (*func) (dba_get_msg (DBA_M_OPEN_SCHEMA, "%s", 0, sch_ptr->name, NP)); }

  sprintf (sqltxt, "open schema %s", sch_ptr->name);
  status = dba_sql (sqltxt);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

  sch_ptr->open = 1;
  if (msg)
    { func = dba_inq_service (DBA_CLEAR_MSG);
    if (func) (*func) (); }

  return (0);
}
