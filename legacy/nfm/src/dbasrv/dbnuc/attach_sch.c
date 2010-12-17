/* $Revision: 1.1 $ */
#include "dba.ext"
extern struct dba_sch *dba_csch, *dba_fsch;
extern char *dba_errtxt;

/* Function:	dba_attach_schema

Description:	sets default schema by passing the schema number, which
		is stored in report and menu structures, instead of 
		schema name, as does dba_attach_db

Author:         Brian Potter
*/
int dba_attach_schema (schema, msg)
int schema, msg;
{
  int status;
  struct dba_sch *tsch;

  if (!dba_csch || dba_csch->schema != schema)
    { for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
      if (tsch->schema == schema) break;
    if (!tsch)
      { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHEMA, "%ld",0, 
        (long) schema, NP));
      return (99); }

    status = dba_attach_db (tsch->name, msg);
    if (status) return (99); }

  return (0);
}
