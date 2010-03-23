#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   hashfree  --  Free all memory allocated to a hash table including the   *
 *		   records it contains (if possible).  The KEEP option is    *
 *		   ignored by hashfree but only those records currently part *
 *		   of the table are freed (the links to the others have been *
 *		   lost).  Hashfree does not return a value.		     *
 *									     *
 *****************************************************************************/

void hashfree (table)

HASHTABLE *table;
{
  HCHAIN *chain;
  int     index;

  /* free all data records allocated via malloc */

  if (table->options & (MALLOC | FREE))
    for (index = 0; index < table->tbllength; index++)
      for (chain = table->body[index]; chain; chain = chain->next)
        free (chain->record);

  /* free all arrays of chain headers and/or data records */

  for (index = 0; index < table->psize; index++)
    free (Vdat(table->ptrs)[index]);

  /* finally, free the vla and the hash table itself */

  vlafree (table->ptrs);
  free (table);
}
