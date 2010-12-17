/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern int dba_mnunum;
int dba_table_selected;
extern struct dba_ent *dba_cent;
extern Form dba_form[];

/* Function:  dba_table_select
   Author:    Tim A. Thompson
   Date:      22-APR-91 (Date moved from dba_s_table_select
*/

int dba_table_select (schema, table)
char *schema, *table;
{
  int status;
  int (*func)();
  struct dba_ent *tent;

  if (schema && strcmp (schema, "0"))
    { status = dba_schema_select (schema);
    if (status) return (status); }

  status = dba_set_ent_ptr (0, 0, table, &tent, 1, 1);
  if (status) return (status);

  dba_cent = tent;
  dba_table_selected = dba_mnunum;
  func = dba_inq_service (DBA_DBFORMS_SET_TABLE);
  if (func) (*func) ();
  dba_table_selected = 0;

  return (0);
}
