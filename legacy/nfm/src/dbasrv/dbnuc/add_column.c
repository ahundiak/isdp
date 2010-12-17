/* $Revision: 1.1 $ */
#include "dba.ext"
/* Function:	dba_add_column */
int dba_add_column (ent_ptr, att_ptr)
struct dba_ent *ent_ptr;
struct dba_att *att_ptr;
{
  struct dba_att *new_att;

  dba_malloc_att (&new_att, att_ptr);
  dba_add_att_ptr (ent_ptr, new_att, NP);

  return (0);
}
