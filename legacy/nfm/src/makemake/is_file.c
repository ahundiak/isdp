
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <sys/types.h>
#include <sys/stat.h>

is_file (f)
char *f;
 {
  struct stat statbuff;
  int i;

  i = stat (f,&statbuff);
  if (i) return (0);
  return (1);
 }
