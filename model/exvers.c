#include "exdate.h"
#include "exvers.h"

extern char EX_version[50];
extern char EX_date[35];

EX_get_version ()

 {
    strncpy (EX_version, exverstr,sizeof(EX_version) - 1 );
    EX_version[sizeof(EX_version) - 1] = '\0';
    strncpy (EX_date, exdatestr, sizeof(EX_date) - 1);
    EX_date[sizeof(EX_date) - 1 ] = '\0';
 }
