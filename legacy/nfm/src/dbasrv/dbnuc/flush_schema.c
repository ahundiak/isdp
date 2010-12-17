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
extern struct dba_ent *dba_cent;

/* Function:	dba_flush_schema

Description: 	causes DBA to rebuild schema definition, useful if
		tables or codelists have been added or modified
		outside of DBA

Author: 	Brian Potter

Revisions:
	9-24-93  -- (TAT) Set dba_cent to zero.

*/
int dba_flush_schema (schema)
char *schema;
{
  int status, count;
  struct dba_sch *tsch;

  status = dba_set_sch_ptr (0, schema, &tsch, 1);
  if (status) return (status);

  tsch->built = 0;
  tsch->code_built = 0;
  dba_cent = 0;
  status = dba_set_sch_ptr (0, schema, &tsch, 1);
  if (status) return (status);

  for (count=1; count<=100; ++count)
    { if (!dba_ment[count]) continue;
    if (dba_ment[count]->schema == tsch->schema) 
      dba_ment[count]->built = 0; }

  return (0);
}
