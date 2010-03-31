/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include <stdio.h>
#include "igrtypedef.h"

/*
 * This function can be used to obtain the first character from
 * stdin. Input upto (and including) the carriage return is read
 * and the first character of such a string is returned. Note that
 * this could even be the carriage return. But due to some residual
 * carriage return hanging around in the buffer, a logically 
 * non-existent one may be falsely construed to exist. At the cost of
 * some pain, the first carriage return is tossed out. Therefore,
 * the user may have to type ONE OR TWO carriage returns for a single
 * carriage return to be understood.
 */

IGRint EFgetchar (fileptr, string, inchar) 
FILE *fileptr;
IGRchar string[], *inchar;
{ 
  IGRchar tmpchar;

  fprintf (fileptr, "%s", string);
  tmpchar = *inchar = getchar();
  if (tmpchar == '\n')
    {
    fprintf (fileptr, "%s", string);
    *inchar = tmpchar = getchar();
    }
  while (tmpchar != '\n')
    tmpchar = getchar();
}
