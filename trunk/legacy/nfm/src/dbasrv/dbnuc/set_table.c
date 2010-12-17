/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern struct dba_sch *dba_csch;

/* Function:	dba_set_table_list 

Description: 	allows user specification of the tables available.
                if list == 0, all tables in database are added

Author: 	Brian Potter
*/
int dba_set_table_list (schema, list)
char *schema, *list;
{
  char tablename[33], *char_ptr;
  int status;
  int (*func)();
  struct dba_sch *tsch;
  struct dba_ent *tent;

  status = dba_set_sch_ptr (0, schema, &tsch, 1);
  if (status) return (status);

  if (list) 
    { for (tent=tsch->fent; tent; tent=tent->nent)
      tent->not_listed = 1;

    char_ptr = list;
    for (;;)
      { status = dba_parse_string (&char_ptr, tablename, ' ', 1);
      if (!status) break;
      status = dba_add_to_table_list (schema, tablename); } }

  else
    for (tent=tsch->fent; tent; tent=tent->nent)
      tent->not_listed = 0;

  if (tsch == dba_csch)
    { func = dba_inq_service (DBA_DBFORMS_SET_TABLE_LIST);
    if (func) (*func) (); }

  return (0);
}
