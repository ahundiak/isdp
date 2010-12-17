/* $Revision: 1.1 $ */

#if defined RIS5
#include "dba.ext"
#include "keys.def"
#include "ris.h"
#include "ris_err.h"

extern int dba_batch_mode, dba_dap_batch_mode;

/* Function:	dba_declare_schema */
int dba_declare_schema (schema)
char *schema;
{
  char sqltxt[100];
  int status;
  int (*func)();
  static char username[32], password[32];

  if (!dba_batch_mode && !dba_dap_batch_mode) {
    func = dba_inq_service (DBA_GET_USER_PASS);
    if (func) {
      status = (*func) (username, password);
      if (!status || status == 99) return (99);
    }
    else 
      return (99);
  }
  else
    return (99);

  sprintf (sqltxt, "declare schema %s user %s.%s", schema, username, password);
  status = dba_exec_sql (sqltxt);
  if (dba_get_sqlcode != RIS_SUCCESS) {
    dba_sqlerr ();
    return (99);
  }
  return (0);
}
#endif
