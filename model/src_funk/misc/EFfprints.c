/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
# include <stdio.h>

int EFfprints(fp, string)
FILE *fp;
char *string;
{
    if(! fp) fp = stderr;
    return fprintf(fp, "%s", string ? string : "");
}
