/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "msmacros.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
/*
Description
    This method gets the current description for this solid.

Return Values
    MSSUCC always

Notes

History
   gupta    07/19/89  Creation Dtae
*/
{
 *msg = MSSUCC;

 strcpy(info->type, "Area/Mass Property");

 return(OM_S_SUCCESS);
}

end implementation EMSmassprop;
