#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   hashlookup  --  search the hash table for a record whose key matches    *
 *		     the given key.  Returns a pointer to the record if it   *
 *		     was found, NULL if it was not.			     *
 *									     *
 *****************************************************************************/

void *hashlookup (table, findkey)

HASHTABLE *table;
char      *findkey;
{
  HCHAIN *chain;
  HCHAIN *pchain;
  int     hashindex;

  /* a hashlookup cancels linear mode */

  table->linear = 0;
  table->delete = 0;

  /* get the hash table index for the supplied key */

  hashindex = table->hashfn (findkey, table->tbllength);

  /* search this chain for the record */

  pchain = (HCHAIN *)&table->body[hashindex];
  for (chain = pchain->next; chain; chain = (pchain = chain)->next)
    if (table->compfn (findkey, KEY (chain->record)) == 0) {
      table->c_index = hashindex;
      table->c_chain = pchain;
      return chain->record;
    }

  /* if we got out of the above loop, a matching key was not found */

  table->c_index = -1;
  return 0;
}
