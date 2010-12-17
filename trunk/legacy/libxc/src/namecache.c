/*****************************************************************************/
/*             THESE ARE CURRENTLY PRIVATE INTERNAL ROUTINES                 */
/*                 DO NOT DOCUMENT THEM AT THIS TIME!!!                      */
/*****************************************************************************/
#include "hash.h"

#define  AVGNAMELEN  18		/* average name length */
#define  GROWFACTOR  1.5	/* cache growth factor */

typedef struct ncache NAMECACHE;
struct ncache {
    int        next;
    int        alloc;
    char      *cache;
    HASHTABLE *dups;
};

static char *addrec;


static void modify_records (NAMECACHE *cache, char *new)
{
  char **record;
  int    adjust = new - cache->cache;

  while (record = hashnext (cache->dups))
    *record += adjust;
}


void *namecache_init (int size, int usedups)
{
  NAMECACHE *new;

  if (   !(new = malloc (sizeof (NAMECACHE)))
      || !(new->cache = malloc (size))       )
    return 0;
  if (!usedups)
    new->dups = 0;
  else if (!(new->dups = hashinit (NAKED(char *),
                          size / AVGNAMELEN, hashc, strcmp, NAKEDKEY, INDKEY)))
    return 0;

  new->next  = sizeof (int);
  new->alloc = size;
  return (void *)new;
}


int namecache_add (void *cache, char *name)
{
  NAMECACHE *names = (NAMECACHE *)cache;
  char     **found;
  int        len, ndx;

  /* check for name already in cache */

  if (names->dups && (found = hashlookup (names->dups, name)))
    return (*found - names->cache);

  /* do I need to enlarge the current cache? */

  if ((ndx = names->next + (len = strlen (name) + 1)) > names->alloc) {
    char *new = realloc (names->cache, ndx *= GROWFACTOR);

    if (!new)
      return 0;
    names->alloc = ndx;
    if (names->dups && new != names->cache)
      modify_records (names, new);
    names->cache = new;
  }

  /* add name to cache */

  memcpy (names->cache + (ndx = names->next), name, len);
  if (names->dups) {
    addrec = names->cache + ndx;
    hashadd (names->dups, &addrec, 0);
  }
  names->next += len;

  return ndx;
}


char *namecache_fini (void *cache)
{
  NAMECACHE *names    = (NAMECACHE *)cache;
  char      *rawcache = names->cache;
  int        rawsize  = names->next;

  if (names->dups) {
    hashinfo (names->dups);
    hashfree (names->dups);
  }
  free (names);
  *(int *)rawcache = rawsize;
  return realloc (rawcache, rawsize);
}
