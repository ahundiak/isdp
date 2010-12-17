/* $Revision: 1.1 $ */
#include "dba.ext"

/* Function:	dba_delete_att_ptr */
int dba_delete_att_ptr (fatt, latt, att)
struct dba_att **fatt, **latt, *att;
{
  if (!att->patt) *fatt = att->natt;
  else att->patt->natt = att->natt;
  if (!att->natt) *latt = att->patt;
  else att->natt->patt = att->patt;

  return (0);
}
