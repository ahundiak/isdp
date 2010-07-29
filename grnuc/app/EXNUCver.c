#include "version.h"
INGR_S_PRODUCT_DEF EXNUC_appl_version_id = {"I/EXNUC   03.04.00.20 27-Jul-10",0,"",0};

/* Copied this from target/exnuc/bin */
#define exdatestr "Tue Jul 27 12:41:56 CDT 2010"
#define exverstr "I/EXNUC version 03.04.00.20"

extern char EX_version[50];
extern char EX_date[35];

EX_get_version ()

 {
    strncpy (EX_version, exverstr,sizeof(EX_version) - 1 );
    EX_version[sizeof(EX_version) - 1] = '\0';
    strncpy (EX_date, exdatestr, sizeof(EX_date) - 1);
    EX_date[sizeof(EX_date) - 1 ] = '\0';
 }

