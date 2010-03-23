#include "hashpvt.h"
#define  INCSIZE  5

/*****************************************************************************
 *									     *
 *   hashdlookup  --  search the hash table for all records whose key        *
 *		      matches the given key.  The address of an array con-   *
 *		      taining pointers to these records is returned in       *
 *		      *arrayptr (the array is allocated using malloc).       *
 *		      Hashdlookup returns the number of records found.       *
 *									     *
 *****************************************************************************/

int hashdlookup (table, findkey, arrayptr)

HASHTABLE   *table;
char        *findkey;
char      ***arrayptr;
{
  HCHAIN  *chain;
  char   **reclist;
  int      hashindex;
  int      listalloc = INCSIZE;
  int      numrecs = 0;

  /* get the initial array allocation */

  reclist = (char **)malloc (listalloc * sizeof (char *));

  /* a hashdlookup cancels linear mode; the current entry becomes undefined
     as well */

  table->linear  = 0;
  table->delete  = 0;
  table->c_index = -1;

  /* get the hash table index for the supplied key */

  hashindex = table->hashfn (findkey, table->tbllength);

  /* search this chain for the record */

  for (chain = table->body[hashindex]; chain; chain = chain->next)
    if (table->compfn (findkey, KEY (chain->record)) == 0) {
      if (numrecs >= listalloc)
        reclist = (char **)realloc (reclist, (listalloc += INCSIZE) * sizeof (char *));
      reclist[numrecs++] = chain->record;
    }

  /* finally, return the results */

  if (numrecs == 0) {
    free (reclist);
    *arrayptr = 0;
  }
  else *arrayptr = reclist;
  return numrecs;
}
