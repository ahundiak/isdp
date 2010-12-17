/* $Revision: 1.1 $ */
#include "dba.ext"
#include "cursor.def"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

extern char *dba_errtxt;
extern struct dba_sch *dba_fsch;

/* Function:    dba_check_for_table */
int dba_check_for_table (schema, tabnam)
int schema;
char *tabnam;
{
  char sqltxt[200];
  int status;
  struct dba_sch *tsch;

  for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
    if (tsch->schema == schema) break;
  if (!tsch)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHEMA, "%ld", 0, 
      (long) schema, NP));
    return (99); }

  sprintf (sqltxt, "select * from %s.%s", tsch->name, tabnam);
  status = dba_select (DBA_C1, NP, sqltxt);
  if (status != RIS_SUCCESS) return (99);

  status = dba_close_cursor (DBA_C1);

  return (0);
}
