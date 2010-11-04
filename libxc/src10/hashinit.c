#include "hashpvt.h"

int _hashblk;

HASHTABLE *_hashinit (tsize, hashfn, compfn, koffset, rsize, options)

int     tsize;             /* number of slots to allocate to the table   */
int     (*hashfn) ();      /* hashing function to use                    */
int     (*compfn) ();      /* key comparison function                    */
int     koffset;           /* offset within record of the key field      */
int     rsize;             /* record size (0 means variable)             */
int     options;           /* hashing options                            */
{
  HASHTABLE  *table;

  /* modify input options setting ones implied by specified options */

  if (options & NOMEM) {
    options &= ~MALLOC;
    if (!(options & FREE))
      options |= KEEP;
  }
  else {
    options &= ~FREE;
    if (options & VLREC)
      options |= MALLOC;
  }
  if (options & FREE && options & KEEP)
    options &= ~(FREE | KEEP);
  if (options & MALLOC && !(options & KEEP))
    options |= FREE;

  /* allocate the hash table and initialize its header */

  table = (HASHTABLE *)calloc (1,
                         sizeof (HASHTABLE) + (tsize - 1) * sizeof (HCHAIN *));
  table->options   = options;
  table->koffset   = koffset;
  table->recsize   = ((options & VLREC) ? 0 : rsize);
  table->tbllength = tsize;
  table->hashfn    = hashfn;
  table->compfn    = compfn;
  table->psize     = 0;
  table->c_index   = -1;

  if (options & MBLOCK)
    table->blkno = _hashblk;

  /* initialize the free list of chain headers */

  Vinit (table->ptrs, 5, 5);
  GETHEADERS;

  /* initialize the free list of hash records if it is needed (the free list
     is needed if neither MALLOC nor NOMEM is set) */

  if (!(options & MALLOC || options & NOMEM))
    GETRECORDS;

  return table;
}
