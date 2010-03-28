/* #######################    APOGEE COMPILED   ######################## */
#include "RAPdate.h"
#include "RAPvers.h"

extern char RAP_version[];
extern char RAP_date[];

int RAP_get_version()

 {
   strcpy (RAP_version, RAPverstr);
   strcpy (RAP_date, RAPdatestr);

   return 1;
 }
