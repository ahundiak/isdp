/* $Revision: 1.2 $ */
/* Function:	dba_add_att_ptr

Description:	adds the passed attribute to the end of the passed
		entity's linked list and increments anumtot.

Author:		Brian Potter
*/
#include "dba.ext"
int dba_add_att_ptr (ent_ptr, new_att, cur_att)
struct dba_ent *ent_ptr;
struct dba_att *new_att, *cur_att;
{
  if (!ent_ptr) return (0);

  if (!cur_att && !ent_ptr->fatt)
    { ent_ptr->fatt = new_att;  ent_ptr->latt = new_att; }
  else if (!cur_att && ent_ptr->fatt)
    { ent_ptr->latt->natt = new_att;  new_att->patt = ent_ptr->latt;
    ent_ptr->latt = new_att; }
  else if (cur_att)
    { if (!cur_att->patt)
      ent_ptr->fatt = new_att;
    else if (cur_att->patt)
      { cur_att->patt->natt = new_att;  new_att->patt = cur_att->patt; }
    cur_att->patt = new_att; }

  new_att->natt = cur_att;  
  ++ent_ptr->anumtot;

  return (0);
}
