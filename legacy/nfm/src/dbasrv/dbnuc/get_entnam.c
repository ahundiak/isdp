/* $Revision: 1.1 $ */
/* Function:	dba_get_entnam 

Description: 	returns the entity name of the specified entity number

Author: 	Brian Potter
*/
#include "dba.ext"

extern struct dba_sch *dba_csch, dba_ssch;
extern char *dba_errtxt;
extern int dba_type;

int dba_get_entnam (entnum, text_ptr)
int entnum;
char *text_ptr;
{
  struct dba_sch *tsch=0;
  struct dba_ent *tent;

  switch (dba_type)
    { case DATBAS:
      tsch = dba_csch;  break;
    case USERDATA: case BINARY: case ASCII:
      tsch = &dba_ssch;  break; }

  if (!tsch) return (0);
  for (tent=tsch->fent; tent; tent=tent->nent)
    if (tent->entnum==entnum)
      { strcpy (text_ptr, tent->entnam);  return (0); }

  dba_append_error (0, dba_get_msg (DBA_E_NO_ENTITY, "%ld", 0, 
    (long) entnum, NP));
  sprintf (text_ptr, "%d", entnum);

  return (99);
}
