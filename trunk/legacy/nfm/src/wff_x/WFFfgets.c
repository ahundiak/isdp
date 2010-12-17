#include "machine.h"
#include <stdio.h>

char *_WFFfgets (s, n, stream)
  char	*s;
  int	n;
  FILE	*stream;
  {
	char *sts, *strchr ();

	if ((sts = fgets (s, n, stream)) == NULL)
		return (sts);

	if ((sts = strchr (s, '\n')) == NULL)
		return (s);

	*sts = NULL;

    return (s);
  }
