#include "machine.h"
#include <stdio.h>

char *CVTfgets(s,n,stream)
    char *s;
    int n;
    FILE *stream;

  {
    char *sts,*strchr();

    if ((sts = fgets(s,n,stream)) == NULL)
      return(sts);
    if ((sts = strchr(s,'\n')) == NULL)
      return(s);
    *sts = 0;
    return(s);
  }
