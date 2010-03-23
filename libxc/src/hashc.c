#define LIMIT    sizeof (long) - 1    /* index a long as a character string */

/*****************************************************************************
 *									     *
 *   hashc  --  determine table index of a character string.		     *
 *									     *
 *****************************************************************************/

int hashc (key, tblsize)

char *key;
int   tblsize;
{
  int   hashval = 0;
  int   i;
  long  grouper;
  char *here;

  for (i = 0, here = key; *here != '\0'; here++) {
    ((char *)&grouper)[i] = *here;
    if (i == LIMIT) {
      hashval ^= grouper;
      i = 0;
    } else i++;
  }

  if (i != 0) {
    for (; i <= LIMIT; i++)
      ((char *)&grouper)[i] = '\0';
    hashval ^= grouper;
  }

  return hashval % tblsize;
}
