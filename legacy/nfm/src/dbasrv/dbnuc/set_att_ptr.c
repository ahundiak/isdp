/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

/* Function:	dba_set_att_ptr 

Description: 	returns an attribute pointer
	
Author: 	Brian Potter
*/
int dba_set_att_ptr (ent_ptr, entnam, attnam, att_ptr, msg, alias)
struct dba_ent *ent_ptr;
char *entnam, *attnam;
struct dba_att **att_ptr;
int msg, alias;
{
  char schent[50];
  int status;
  int (*func)();
  struct dba_sch *tsch;
  struct dba_att *tatt, *att1, *att2;

  if (!ent_ptr)
    { status = dba_set_ent_ptr (0, 0, entnam, &ent_ptr, 1, 0);
    if (status) return (status); }
  if (!ent_ptr->built)
    { if (msg)
      { func = dba_inq_service (DBA_PRINT_MSG);
      if (func) 
        (*func) (dba_get_msg (DBA_M_BUILD_ATT, "%s", 0, ent_ptr->alias, NP)); }
    for (att1=att2=ent_ptr->fatt; att2; )
      { att2 = att1->natt;  dba_free_att (&att1);  att1 = att2; }
    ent_ptr->fatt = 0;  ent_ptr->latt = 0;
    status = dba_build_att (ent_ptr, 0);
    if (msg) 
      { func = dba_inq_service (DBA_CLEAR_MSG);
      if (func) (*func) (); }
    if (status) return (99); }

  for (tatt=ent_ptr->fatt; tatt; tatt=tatt->natt)
    if (entnam && attnam && strcmp (tatt->entnam, entnam) == 0)
      { if (!alias && strcmp (tatt->attnam, attnam) == 0)
        { *att_ptr = tatt;  return (0); }
      else if (alias && strcmp (tatt->alias, attnam) == 0)
        { *att_ptr = tatt;  return (0); } }

  status = dba_set_sch_ptr (ent_ptr->schema, NP, &tsch, msg);
  if (status) sprintf (schent, "%s.%s", tsch->name, entnam);
  else strcpy (schent, entnam);

  dba_append_error (0, dba_get_msg (DBA_E_NO_COLUMN, "%s%s", 0, 
    schent, attnam));
  *att_ptr = 0;

  return (99);
}
