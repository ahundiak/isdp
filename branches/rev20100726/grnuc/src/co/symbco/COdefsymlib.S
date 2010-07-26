/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COdefsymlib

Description
   This is the class used to define an active cell library.

History
   BC     06/12/86 : Design date.
   HGW    07/03/86 : Finish coding and tested.
   HGW    12/15/87 : Changes for version 1.1
\*/

class specification COdefsymlib (1:0) of COroot;

#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "grsymdef.h"
#include "grsym.h"

instance COdefsymlib
{
   IGRint                     init_success;  /* init flag               */
   struct GRevent             event;         /* Keyin event             */
   struct GRsymbol_lib_file   asl_file;      /* DPB symbol structure    */
};

override init, execute;

end specification COdefsymlib;
