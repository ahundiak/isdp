/* $Revision: 1.1 $ */
#include "dba.ext"
extern struct dba_sch * dba_csch, *dba_fsch, *dba_lsch;

/* Function:	dba_clear_schema_list 

Description:	frees all memory allocated in the current schema list


Author:         Brian Potter
*/
int dba_clear_schema_list ()
{
  struct dba_sch *tsch, *csch;

  for (csch=tsch=dba_fsch; tsch; )
    { tsch = csch->nsch;  dba_dfree (csch);  csch = tsch; }

  dba_fsch = 0;
  dba_lsch = 0;
  dba_csch = 0;

  return (0);
}
