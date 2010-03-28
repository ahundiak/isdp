/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRget_projection_angle

Description
    This method returns the projection angle.

Arguments
    *msg           IGRlong              completion code 
    *angle         IGRint               the projection angle
                                        -  GR_DS_FIRST_ANGLE
                                        -  GR_DS_THIRD_ANGLE

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn      08/02/88    Creation date
\*/

class implementation GRdrawview;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dsdef.h"
#include "ds.h"
#include "dsmacros.h"

extern IGRint GRget_to_owner_info();

method GRget_projection_angle (IGRlong *msg; IGRint *angle)
{
    IGRlong           ret_msg;
    IGRint            count;
    IGRint            i;
    IGRlong           temp;
    IGRlong           size;
    IGRshort          prop;
    IGRchar           dpb_proj_angle;
    GRclassid         classid;
    GRclassid         ds_classid;
    OM_S_CHANSELECT   chansel;
    struct GRid       go_id;

    *msg = MSSUCC;

    GRget_to_owner_info(&chansel, OM_Gw_current_OS, my_id, &count);

    /*
     *  Send a message out the owners channel to all drawing sheets.
     */
    om$get_classid ( classname = "GRdrawsheet",
                     p_classid = &ds_classid );

    ret_msg = MSFAIL;
    for (i = 0; i < count; ++i) 
    {
        om$get_objid_at_index ( osnum = OM_Gw_current_OS, 
                                objid = my_id,
                                p_chanselect = &chansel, 
                                index = i,
                                objidaddr = &go_id.objid, 
                                osnumaddr = &go_id.osnum );

        om$get_classid ( osnum = go_id.osnum, 
                         objid = go_id.objid,
                         p_classid = &classid );

        if (classid == ds_classid) 
        {
            om$send ( msg = message GRowner.GRget_owner_properties (&ret_msg, &prop),
                      targetid = go_id.objid, 
                      targetos = go_id.osnum );
            break;
        }
    }

    /*
     * If there was a drawing sheet as an owner get the projection angle from it 
     * otherwise get the projection angle from the dpb.
     */
    if (ret_msg & 1) 
    {
        *angle = (prop & GR_DS_FIRST_ANGLE) ? 
                 GR_DS_FIRST_ANGLE : GR_DS_THIRD_ANGLE;
    }
    else 
    {
        size = sizeof (IGRchar);
        gr$get_projection_angle ( msg = msg, 
                                  sizbuf = &size, 
                                  buffer = &dpb_proj_angle, 
                                  nret = &temp );

        *angle = (dpb_proj_angle == DS_THIRD_ANGLE) ? 
                 GR_DS_THIRD_ANGLE : GR_DS_FIRST_ANGLE;
    }

    return (OM_S_SUCCESS);
}
end implementation GRdrawview;
