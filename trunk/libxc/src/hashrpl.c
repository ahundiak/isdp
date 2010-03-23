#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   hashrpl  --  replace the current entry with the one supplied.  The key  *
 *		  value of the supplied entry must match that of the one     *
 *		  being replaced.  This entry becomes the current entry.     *
 *		  The "size" parameter may be omitted if the VLREC option    *
 *		  is not set.  A pointer to the new entry is returned on     *
 *		  success; NULL is returned on error.			     *
 *									     *
 *****************************************************************************/

void *hashrpl (table, rplwith, size)

HASHTABLE *table;
char      *rplwith;
int        size;
{
  int recsize;

  /* make sure there is a candidate entry first */

  if (table->c_index == -1 || table->delete)
    return 0;

  /* make sure that the key values match */

  if (table->compfn (KEY (rplwith), KEY (table->c_chain->next->record)) != 0)
    return 0;

  /* free the original space if we can't reuse it */

  if (table->options & (VLREC | NOMEM) && table->options & FREE)
    free (table->c_chain->next->record);

  /* simply use the supplied pointer if memory management is disabled */

  if (table->options & NOMEM)
    return table->c_chain->next->record = rplwith;

  /* allocate new space if we need it */

  recsize = (table->options & VLREC ? size : table->recsize);
  if (table->options & (KEEP | VLREC))
    if (table->options & MALLOC)
      table->c_chain->next->record = malloc (recsize);
    else {
      if (!table->rfree)
        GETRECORDS;
      table->rfree = *(char **)(table->c_chain->next->record = table->rfree);
    }

  /* finally we copy the data and return a pointer to it */

  return (void *)memcpy (table->c_chain->next->record, rplwith, recsize);
}
