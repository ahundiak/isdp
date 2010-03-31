/*
Name

    EFmake_pointers

Abstract

        This function creates pointers for the specified owner's components
    if they are subclassed from EMSsubbs or the flag always_create is set to
    TRUE.

Synopsis
        Type                    Name           I/O      Description
 ---------------------- ---------------------- --- ------------------------
 IGRlong                *EMmsg                  O  The return code.
 struct GRid            *owner_obj              I  The object id and osnum
                                                   of an owner object.
 IGRint                  always_create          I  If TRUE, create pointers
                                                   for components
                                                   unconditionally, else
                                                   check to see if component
                                                   is subclassed from
                                                   EMSsubbs.
Description

        This function creates pointers for the specified owner's components
    if either they are subclassed from EMSsubbs or the flag always_create is
    set to TRUE.  If a component is an owner object, this function is called
    recursively to create pointers for its components.
        If the global flag ASbroadcast_in_progress is set to TRUE,
    pointers will not be created since the flag indicates associative elements
    are being updated.  We don't want to create pointers in this case since
    during a recompute a newly created element is displayed before the
    elements connected to its old object's channels are moved to the new
    object.  There should already be pointer objects on the old object, which
    would be moved to this new object.  If we allowed pointers to be created
    for the new object in this case, the method move_chan would fail during
    EMastore since there would already be pointer objects connected to the
    new object.

Keywords

    function

History
         
    05/07/93 : WBC : Creation Date.

*/

class implementation EMSsurface;

#include "EMS.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "bsparameters.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "EMSprop.h"
#include "EMSxsection.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igrtypedef.h"    /* needed for gocmacros.h */
#include "EMSopt.h"
#include "bs.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"
#include "madef.h"
#include "EMSlcdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "EMptrmacros.h"

from EMSedge import EMget_props;
from EMSboundary import EMgetxyzobj;

extern GRclassid OPP_EMSsubbs_class_id;
extern GRclassid OPP_EMSagrp_class_id;
extern GRclassid OPP_GRcmpowner_class_id;

extern IGRboolean ASbroadcast_in_progress;


IGRint EFmake_pointers(EMmsg, owner_obj, always_create)

IGRlong         *EMmsg;
struct GRid     *owner_obj;
IGRint           always_create;
{
    IGRlong                     OM_stat,
                                rc;
    IGRint                      index;
    OMuint                      num_cmpnts;
    OMuword                     comp_classid;
    OM_S_CHANSELECT	        to_components_chan;
    struct GRid                 component_grid,
                                src_parent;

    /* associative update is in progress; don't want to create pointers at
     * this time since the pointers on the objects being recomputed will be
     * moved to their newly created objects
     */

    if (ASbroadcast_in_progress)
        goto wrapup;

    OM_stat = EMmake_chanselect(GRcmpowner_to_components, &to_components_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    OM_stat = om$get_channel_count(osnum = owner_obj->osnum,
                                   objid = owner_obj->objid,
                                   p_chanselect = &to_components_chan,
                                   count = &num_cmpnts);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if (num_cmpnts)
    {
        for (index = 0; index < num_cmpnts; index++)
        {
            OM_stat = om$get_objid_at_index(osnum = owner_obj->osnum,
                                            objid = owner_obj->objid,
                                            p_chanselect = &to_components_chan,
                                            index = index,
                                            objidaddr = &component_grid.objid,
                                            osnumaddr = &component_grid.osnum);

            if (1 & OM_stat)
            {
                OM_stat = om$get_classid(osnum = component_grid.osnum,
                                         objid = component_grid.objid,
                                         p_classid = &comp_classid);
                if (!(1 & OM_stat))
                {
                    *EMmsg = EMS_E_Fail;
                    goto wrapup;
                }

                if ((always_create) ||
                    (om$is_ancestry_valid(subclassid = comp_classid,
                       superclassid = OPP_EMSsubbs_class_id) == OM_S_SUCCESS))
                {
                    /* create a pointer for this component object */

                    ems$return_indirection(msg = &rc,
                                           component = &component_grid,
                                           pointer = &src_parent);
                }

                if (om$is_ancestry_valid(subclassid = comp_classid,
                       superclassid = OPP_GRcmpowner_class_id) == OM_S_SUCCESS)
                {
                    /* recursive call to make pointers for the components
                     * of this owner
                     */

                    EFmake_pointers(EMmsg, &component_grid, always_create);
                }
            }
        }
    }

wrapup:

    *EMmsg = EMS_S_Success;

    return(OM_S_SUCCESS);
}

end implementation EMSsurface;
