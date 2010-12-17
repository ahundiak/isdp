
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
#include <ctype.h>

int fget_str (str,infile)
char *str;
FILE *infile;
 {
  int i;
  int c;
  int endc;

  while (1)
   {
    c = fgetc (infile);
    if (c == EOF) return (0);
    if (isgraph(c)) break;
   }
  i = 0;
  if (c == '<')
   endc = '>';
  else
   endc = c;
  c = fgetc (infile);
  if (c == EOF) return (1);
  while (1)
   {
    if (c==endc)
     {
      str[i] = 0;
      return (endc);
     }
    if (c==EOF)
     {
      str[i] = 0;
      return (endc);
     }
    if (isspace(c))
     {
      str[i] = 0;
      return (endc);
     }
    str[i] = c;
    c = fgetc (infile);
    i++;
   }
 }
