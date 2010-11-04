#include <strings.h>
#include <memory.h>
#include <malloc.h>

#define  ALIGNSZ            8         /* machine alignment requirement  */
#define  MINELEM    sizeof (ELEMENT)  /* minimum element size           */
#define  NUMSLOTS          15         /* number entries in free queue   */
#define  BUCKETSZ          25         /* number elements per bucket     */
#define  MAXBUCKET  (4*NUMSLOTS - 1)  /* longer than this gets malloced */

typedef unsigned char uchar;

#ifndef SUNOS58
typedef unsigned int  uint;
#endif

#define  ELEMENT  union elem
ELEMENT {
          ELEMENT *next;
          uchar    string[2];
};

static ELEMENT *freeq[NUMSLOTS];
static char     zero = '\0';


char *stralloc (ptr)

char *ptr;
{
  ELEMENT *new;
  uint     len = strlen (ptr) + 1;
  uint     ndx = len / MINELEM;

  /* special treatment of null string */

  if (len < 2)
    return &zero;

  /* malloc big strings */

  if (len > MAXBUCKET) {
    char *new = malloc (len);

    return (new ? memcpy (new, ptr, len) : 0);
  }

  /* get an element from the free queue; if empty, get a new bucket */

  if (new = freeq[ndx])
    freeq[ndx] = new->next;
  else {
    uint     cnt;
    uint     elemsz = MINELEM * (ndx + 1);
    ELEMENT *bucket = new = (ELEMENT *)malloc (BUCKETSZ * elemsz);

    if (!bucket)
      return 0;

    for (cnt = BUCKETSZ; --cnt; bucket = bucket->next)
      bucket->next = (ELEMENT *)((char *)bucket + elemsz);
    bucket->next = 0;
    freeq[ndx]   = new->next;
  }

  /* store free queue index in first char; the string starts at the second */

  new->string[0] = ndx;
  return memcpy (&new->string[1], ptr, len);
}

void strfree (ptr)

char *ptr;
{
  uint     ndx;
  ELEMENT *tofree = (ELEMENT *)(ptr - 1);

  /* ALIGNSZ-aligned pointers are assumed to be malloced "big strings" */

  if (!((uint)ptr % ALIGNSZ))
    free (ptr);

  /* otherwise check validity of pointer we've been handed */

  if (ptr == &zero || (uint)tofree % MINELEM)
    return;

  /* add it to the free queue */

  if ((ndx = tofree->string[0]) < NUMSLOTS) {
    tofree->next = freeq[ndx];
    freeq[ndx]   = tofree;
  }
}
