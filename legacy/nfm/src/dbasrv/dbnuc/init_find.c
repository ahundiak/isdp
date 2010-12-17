/* $Revision: 1.1 $ */
#include "dba.ext"
#include "keys.def"

extern char dba_find_name[], dba_find_desc[], *dba_errtxt;
extern struct dba_sch *dba_fsch;
extern struct dba_ent *dba_cent;

/* Function:	dba_init_find */
int dba_init_find ()
{
  int (*func)();
  struct dba_sch *tsch;
  struct dba_ent *tent;

  for (tsch=dba_fsch; tsch; tsch=tsch->nsch)
    for (tent=tsch->fent; tent; tent=tent->nent)
      dba_free_find (tent);

  dba_find_name[0] = 0;
  dba_find_desc[0] = 0;

  func = dba_inq_service (DBA_PAINT_FIND);
  if (func) (*func) (dba_cent);

  strcpy (dba_errtxt, dba_get_msg (DBA_M_FIND_INITED, NP,0,NP,NP));

  return (98);
}
