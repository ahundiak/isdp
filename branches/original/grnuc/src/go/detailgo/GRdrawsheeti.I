/* #######################    APOGEE COMPILED   ######################## */
class implementation GRdrawsheet;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detail.h"
#include "OMmacros.h"
#include "detaildef.h"

extern IGRint GRget_to_comp_chansel();

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
    *msg = MSSUCC;

    ex$message(msgnumb = GR_I_DrwSht, buff = info->type);

    return(OM_S_SUCCESS);
}

method GRget_locate_properties (IGRlong *msg; IGRint *properties)
{
    *msg = MSSUCC;
    *properties = GR_LC_CMP_READ        |
                  GR_LC_CMP_WRITE       |
                  GR_LC_OWN_READ        |
                  GR_LC_OWN_WRITE       |
                  GR_LC_CMP_PRM_READ    |
                  GR_LC_CMP_PRM_WRITE   |
                  GR_LC_FLEXIBLE;

    return (OM_S_SUCCESS);
}

method GRput_drawsheet_description (IGRlong *msg; IGRchar *desc)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send ( msg = OPPmargs, 
                     p_chanselect = &chansel, 
                     from=0, 
                     to=0) );
}

method GRget_drawsheet_description (IGRlong *msg; IGRchar *desc)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send ( msg = OPPmargs, 
                     p_chanselect = &chansel, 
                     from=0, 
                     to=0) );
}

method GRchg_owner_properties ( IGRlong *msg; 
                                IGRint action; 
                                IGRshort *mask)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send ( msg = OPPmargs, 
                     p_chanselect = &chansel, 
                     from=0, 
                     to=0) );
}

method GRget_owner_properties (IGRlong *msg; IGRshort *properties)
{
    OM_S_CHANSELECT   chansel;

    GRget_to_comp_chansel(&chansel);

    return(om$send ( msg = OPPmargs, 
                     p_chanselect = &chansel, 
                     from=0, to=0) );
}

end implementation GRdrawsheet;
