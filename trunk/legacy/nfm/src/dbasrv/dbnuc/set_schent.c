/* $Revision: 1.1 $ */
#include "dba.ext"
extern struct dba_sch dba_ssch, *dba_csch;
extern struct dba_ent *dba_cent;
extern char *dba_errtxt;
extern int dba_type;

/* Function:	dba_set_schent_ptr 

Description:    returns an entity pointer when passed a
		schema (name or number) and a table (name or number)

Author:         Brian Potter
*/

int dba_set_schent_ptr (schema, table, ent_ptr)
char *schema, *table;
struct dba_ent **ent_ptr;
{
  int status, schnum, tabnum;
  struct dba_sch *tsch;
  struct dba_ent *tent;

  switch (dba_type)
    { case DATBAS:
      if (schema)
        { status = sscanf (schema, "%d", &schnum);
        if (status == 1)
          { if (schnum)
            { status = dba_set_sch_ptr (schnum, NP, &tsch, 1);
            if (status) return (status); }
          else
            tsch = dba_csch; }
        else
          { status = dba_set_sch_ptr (0, schema, &tsch, 1);
          if (status) return (status); } }
      else tsch = dba_csch;
      break;
    case USERDATA: case BINARY: case ASCII:
      tsch = &dba_ssch;
      break; }

  if (!tsch)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_CURRENT_SCHEMA, NP, 0, NP, NP));
    return (99); }

  if (table)
    { status = sscanf (table, "%d", &tabnum);
    if (status == 1)
      { if (tabnum)
        { status = dba_set_ent_ptr (tsch->schema, tabnum, 0, &tent, 1, 0);
        if (status) return (status); }
      else
        tent = dba_cent; }
    else
      { status = dba_set_ent_ptr (tsch->schema, 0, table, &tent, 1, 0);
      if (status) return (status); } }
  else tent = dba_cent;
  if (!tent)
    { strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_CURRENT_TABLE, NP,0,NP,NP));
    return (99); }

  *ent_ptr = tent;

  return (0);
}
