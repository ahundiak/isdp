/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_delete_ent_ptr */
int dba_delete_ent_ptr (fent, lent, ent)
struct dba_ent **fent, **lent, *ent;
{
  if (!ent->pent) *fent = ent->nent;
  else ent->pent->nent = ent->nent;
  if (!ent->nent) *lent = ent->pent;
  else ent->nent->pent = ent->pent;

  return (0);
}
