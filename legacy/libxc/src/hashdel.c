#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   hashdel  --  deletes the "current" entry from the specified hash table. *
 *		  This entry is the one returned by the most recent call to  *
 *		  hashadd, hashlookup, hashrpl, or hashnext.  Zero is        *
 *		  returned on success; -1 on error.			     *
 *									     *
 *****************************************************************************/

int hashdel (table)

HASHTABLE *table;
{
  HCHAIN *temp;

  /* make sure there is a "current" entry */

  if (table->c_index == -1 || table->delete)
    return -1;

  /* remove it from the chain */

  table->c_chain->next = (temp = table->c_chain->next)->next;

  /* free up the space used by this record if required */

  if (!(table->options & KEEP))
    if (table->options & FREE)
      free (temp->record);
    else {
      *(char **)temp->record = table->rfree;
      table->rfree           = temp->record;
    }

  /* return the chain header to the free list */

  temp->next   = table->hfree;
  table->hfree = temp;

  /* if linear mode is active, set the delete flag; otherwise clear the
     "current" entry by setting c_index to -1 */

  if (table->linear)
    table->delete = 1;
  else table->c_index = -1;

  return 0;
}
