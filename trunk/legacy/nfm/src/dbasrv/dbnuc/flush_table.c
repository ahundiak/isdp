/* $Revision: 1.1 $ */
#include "dba.ext"

#if defined RIS4
#include "sql.h"
#elif defined RIS5
#include "ris.h"
#else
#include "sql.h"
#include "RISerror.h"
#endif

extern char dba_text[], *dba_errtxt;
extern struct dba_ent *dba_ment[];

/* Function:	dba_flush_table

Description: 	causes DBA to rebuild table definition, useful if
		columns have been added outside of DBA

Author: 	Brian Potter
*/
int dba_flush_table (schema, table)
char *schema, *table;
{
  int status, count;
  struct dba_sch *tsch;
  struct dba_ent *tent;

  status = dba_set_sch_ptr (0, schema, &tsch, 1);
  if (status) return (status);

  status = dba_set_schent_ptr (schema, table, &tent);
  if (status) return (status);

  tent->built = 0;

  for (count=1; count<=100; ++count)
    { if (!dba_ment[count]) continue;
    if (dba_ment[count]->schema == tent->schema
      && strcmp (dba_ment[count]->entnam, tent->entnam) == 0)
      dba_ment[count]->built = 0; }

  sprintf (dba_text, "undeclare table %s.%s", tsch->name, tent->entnam);
  status = dba_sql (dba_text);
  if (status != RIS_SUCCESS) { dba_sqlerr ();  return (99); }

  return (0);
}
