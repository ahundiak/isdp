#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   hashdelrec  --  deletes the given record from the specified hash table. *
 *		     Zero is returned on success; -1 on error.		     *
 *									     *
 *****************************************************************************/

int hashdelrec (table, record)

HASHTABLE *table;
void      *record;
{
  HCHAIN *chain;
  HCHAIN *pchain;
  int     hashindex;

  /* this operation cancels linear mode and the current entry */

  table->linear  =  0;
  table->delete  =  0;
  table->c_index = -1;

  /* get the hash table index for the supplied record */

  hashindex = table->hashfn (KEY (record), table->tbllength);

  /* search this chain for the record */

  pchain = (HCHAIN *)&table->body[hashindex];
  for (; chain = pchain->next; pchain = chain)
    if (chain->record == record)
      goto found;
  return -1;

  /* if we got out of the above loop, the record was found so remove it from
     the chain */

found:
  pchain->next = chain->next;

  /* free up the space used by this record if required */

  if (!(table->options & KEEP))
    if (table->options & FREE)
      free (chain->record);
    else {
      *(char **)chain->record = table->rfree;
      table->rfree            = chain->record;
    }

  /* return the chain header to the free list */

  chain->next  = table->hfree;
  table->hfree = chain;
  return 0;
}
