#include "hashpvt.h"

/*****************************************************************************
 *									     *
 *   hashadd  --  add the record pointed to by "record" to the hashtable     *
 *		  pointed to by "table".  If "dupptr" is not NULL and the    *
 *		  DUPS option is not in effect, a pointer to any existing    *
 *		  record whose key matches that of "record" is returned in   *
 *		  "*dupptr".  "rsize" is the size in bytes of "*record"      *
 *		  (only under the VLREC option - this parameter may be       *
 *		  omitted on the call unless VLREC is set).  Unless the      *
 *		  NOMEM option is in effect, the necessary amount of space   *
 *		  is allocated and the contents of "*record" is copied.  The *
 *		  NOMEM option forces us to use the provided address         *
 *		  ("record") as the actual hash table entry without moving   *
 *		  the data.  A pointer to the added record is returned       *
 *		  unless DUPS is not set and a duplicate record already      *
 *		  exists in the table in which case NULL is returned.        *
 *									     *
 *****************************************************************************/

void *hashadd (table, record, dupptr, rsize)

HASHTABLE *table;     /* pointer to the hash table                         */
void      *record;    /* pointer to the record to be added                 */
void      *dupptr;    /* pointer to location to hold addr of duplicate     */
int        rsize;     /* size of the record (used only under VLREC option) */
{
  HCHAIN *chain;
  HCHAIN *pchain;
  char   *key;
  int     hashindex;
  int     recsize;

  /* a hashadd cancels linear mode */

  table->linear = 0;
  table->delete = 0;

  /* get the hash table index for this record */

  hashindex = table->hashfn (key = KEY (record), table->tbllength);

  /* check to see if the entry is already in the table when duplicate
     insertion is disallowed */

  if (!(table->options & DUPS)) {
    pchain = (HCHAIN *)&table->body[hashindex];
    for (chain = pchain->next; chain; chain = (pchain = chain)->next)
      if (table->compfn (key, KEY (chain->record)) == 0) {
        table->c_index = hashindex;
        table->c_chain = pchain;
        if (dupptr)
          *(void **)dupptr = chain->record;
        return 0;
      }
  }
  if (dupptr)
    *(void **)dupptr = 0;

  /* get a hash chain header so that we can add the record */

  if (!table->hfree)
    GETHEADERS;
  table->hfree = (chain = (HCHAIN *)table->hfree)->next;

  /* set the chain header to point to the new entry */

  if (table->options & NOMEM)
    chain->record = record;
  else {
    recsize = (table->options & VLREC ? rsize : table->recsize);
    if (table->options & MALLOC)
      chain->record = malloc (recsize);
    else {
      if (!table->rfree)
        GETRECORDS;
      table->rfree = *(char **)(chain->record = table->rfree);
    }
    memcpy (chain->record, record, recsize);
  }

  /* add this chain header to the front of the hash chain */

  chain->next            = table->body[hashindex];
  table->body[hashindex] = chain;
  table->c_index         = hashindex;
  table->c_chain         = (HCHAIN *)&table->body[hashindex];
  return chain->record;
}
