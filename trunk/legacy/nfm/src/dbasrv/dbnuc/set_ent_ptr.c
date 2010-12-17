/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern char *dba_errtxt, dba_text[];
extern int dba_type;
extern struct dba_sch dba_ssch, *dba_fsch, *dba_csch;

/* Function:	dba_set_ent_ptr 

Description: 	returns an entity pointer, input entity name or number

Author: 	Brian Potter
*/
int dba_set_ent_ptr (schema, entnum, entnam, ent_ptr, msg, alias)
int schema, entnum, msg, alias;
char *entnam;
struct dba_ent **ent_ptr;
{
  int status;
  int (*func)();
  struct dba_sch *tsch=0;
  struct dba_ent *tent;
  struct dba_att *att1, *att2;

  *ent_ptr = 0;

  if (!entnum && !entnam) return (1);

  switch (dba_type)
    { case DATBAS:
      if (!schema) 
        tsch = dba_csch;
      else
        for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
          if (tsch->schema == schema) break;
      break;
    case USERDATA: case BINARY: case ASCII:
      tsch = &dba_ssch;
      break; }

  if (!tsch)
    { if (!schema)
      strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_CURRENT_SCHEMA, NP, 0, NP, NP));
    else
      strcpy (dba_errtxt, dba_get_msg (DBA_E_NO_SCHEMA, "%ld", 0, 
        (long) schema, NP));
    return (99); }

  status = dba_build_ent (tsch);
  if (status) return (99);

  for (tent=tsch->fent; tent; tent=tent->nent)
    { if (tent->not_listed) continue;
    if (entnum) { if (tent->entnum == entnum) break; }
    else if (entnam)
      { if (!alias && strcmp (tent->entnam, entnam) == 0) break;
      else if (alias && strcmp (tent->alias, entnam) == 0) break; } }

  if (!tent)
    { if (entnum)
      { sprintf (dba_text, "%d", entnum);
      entnam = dba_text; }

    dba_append_error (0, dba_get_msg (DBA_E_NO_SCHENT, "%s%s", 0, 
      tsch->name, entnam));  
    return (99); }

  if (!tent->built)
    { if (msg)
      { func = dba_inq_service (DBA_PRINT_MSG);
      if (func)
        (*func) (dba_get_msg (DBA_M_BUILD_ATT, "%s", 0, tent->alias, NP)); }
    for (att1=att2=tent->fatt; att2; )
      { att2 = att1->natt;  dba_free_att (&att1);  att1 = att2; }
    tent->fatt = 0;  tent->latt = 0;
    status = dba_build_att (tent, schema);
    if (msg)
      { func = dba_inq_service (DBA_CLEAR_MSG);
      if (func) (*func) (); }
    if (status) return (99); }

  *ent_ptr = tent;

  return (0);
}
