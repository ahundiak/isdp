/* $Revision: 1.1 $ */
/* Function:	dba_set_sch_ptr 

Description: 	returns a schema pointer, input schema name or number

Author: 	Brian Potter
*/
#include "dba.ext"
extern struct dba_sch dba_ssch, *dba_fsch, *dba_csch;
extern char *dba_errtxt;
extern int dba_type;

int dba_set_sch_ptr (schema, schnam, sch_ptr, msg)
int schema, msg;
char *schnam;
struct dba_sch **sch_ptr;
{
  int status, schnum;
  struct dba_sch *tsch=0;

  if (schnam)
    { if (schnam[0] == '0' || !strlen (schnam)) schnam = 0;
    else
      { status = sscanf (schnam, "%d", &schnum);
      if (status == 1)
        { schema = schnum;
        schnam = 0; } } }

  switch (dba_type)
    { case DATBAS:
      if (!schema && !schnam) 
        { tsch = dba_csch;  break; }
      if (!dba_fsch && schnam)
        { status = dba_attach_db (schnam, 1);
        if (status) return (status); 
        tsch = dba_csch; }
      else
        for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
          { if (schema) { if (tsch->schema == schema) break; }
          else if (strcmp (tsch->name, schnam) == 0) break; }
      break;
    case USERDATA: case BINARY: case ASCII:
      tsch = &dba_ssch;  break; }

  if (!tsch)
    { if (schema)
      strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHEMA, "%ld", 0, 
        (long) schema, NP));
    else if (schnam)
      strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHNAM, "%s", 0, schnam, NP));
    else
      strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_CURRENT_SCHEMA, NP, 0, NP, NP));
    *sch_ptr = 0;  return (99); }

  status = dba_build_ent (tsch);  if (status) return (status);
  status = dba_open_schema (tsch, msg);  if (status) return (status);
  status = dba_init_codelist (tsch);  if (status) return (status);
  *sch_ptr = tsch;  

  return (0);
}
