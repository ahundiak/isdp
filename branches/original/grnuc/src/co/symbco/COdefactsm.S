/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COdefactsm

Description
   This is the class used to define an active cell.

History
   BC    06/12/86 : Design date.
   HGW   06/30/86 : Finished coding and testing.
   HGW   08/05/86 : Changed terminology
   mrm   10/01/86 : OM 4.0 conversion
   HGW   12/15/87 : Changes for version 1.1
\*/

class specification COdefactsm (1:0) of COroot;

#include "igr.h"
#include "griodef.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"

instance COdefactsm
{
   IGRint         init_success; /* Flag set if TRUE is successful init  */
   struct GRevent event;        /* Event used in for origin             */
};

override init, execute;

end specification COdefactsm;
