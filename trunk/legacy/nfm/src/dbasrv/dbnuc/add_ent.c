/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_add_ent_ptr */
int dba_add_ent_ptr (fent, lent, new_ent, cur_ent)
struct dba_ent **fent, **lent, *new_ent, *cur_ent;
{
  if (!cur_ent && !(*fent))
    { *fent = new_ent;
    *lent = new_ent; }
  else if (!cur_ent && *fent)
    { (*lent)->nent = new_ent;
    new_ent->pent = *lent;
    *lent = new_ent; }
  else if (cur_ent)
    { if (!cur_ent->pent)
      *fent = new_ent;
    else if (cur_ent->pent)
      { cur_ent->pent->nent = new_ent;
      new_ent->pent = cur_ent->pent; }
    cur_ent->pent = new_ent; }

  new_ent->nent = cur_ent;  

  return (0);
}
