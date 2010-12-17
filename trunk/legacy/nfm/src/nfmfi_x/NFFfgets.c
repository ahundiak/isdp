
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>

char *_NFFfgets (s, n, stream)
  char   *s;
  int    n;
  FILE   *stream;
  {
    char *sts, *strchr ();

    if ((sts = fgets (s, n, stream)) == NULL)
        return (sts);

    if ((sts = strchr (s, '\n')) == NULL)
        return (s);

    *sts = NULL;

    return (s);
  }
