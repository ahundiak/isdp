/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRconstruct

Description
    This method is used to perform the initilization of the drawing 
    border.

    *arglist       struct GRvg_construct   Structure used to contain 
                                           arguments for construction.

History
    Gray Winn   08/24/88    Design date.
\*/
class implementation GRdsborder;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detail.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
   *msg = MSSUCC;
 
   ex$message(msgnumb = GR_I_DrwBord, buff = info->type);

   return(OM_S_SUCCESS);
}

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
    *msg = MSSUCC;
    *properties = GR_LC_CMP_READ        |
                  GR_LC_CMP_WRITE       |
                  GR_LC_OWN_READ        |
                  GR_LC_OWN_WRITE       |
                  GR_LC_OWN_PRM_READ    |
                  GR_LC_OWN_PRM_WRITE   |
                  GR_LC_FLEXIBLE;

    return (OM_S_SUCCESS);
}

method GRadd_to_active_owner (IGRlong *msg; struct GRmd_env *mod_env)
{
    *msg = MSSUCC;   
    return (OM_S_SUCCESS);
}

end implementation GRdsborder;
