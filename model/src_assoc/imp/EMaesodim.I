/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for ellipsoids.
 *
 * HISTORY:
 *
 *  jhw    Creation         06/12/91
 */
class implementation EMAelpsoid;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSdimdef.h"
#include "dimplcmacros.h"

from EMSparamgm   import EMgetgeom;

extern OMuword OPP_DMroot_class_id;

method EMdim ( IGRlong             * msg;
               struct GRmd_env     * mod_env;
               IGRushort     options;
               IGRint                type;
               IGRchar             * info;
               IGRint                num_parents;
               struct GRid         * parents )
{
    IGRlong       om_msg = OM_S_SUCCESS, msg_loc;
    struct GRid   assoc_id, source_id, dim_id;
    IGRint        trak_dir;
    IGRpoint      dumpt;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    switch (type)
    {
        case EMS_ASellipsoid_by_center_axis_radius:
        case EMS_ASellipsoid_by_foci_axis_len:
            dim_id.objid = NULL_OBJID;
            trak_dir = 1;
            goto ret_end;
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMAelpsoid.EMdim");

    return (om_msg);
}

method EMdimparam ( IGRlong            * msg; 
                    struct GRmd_env    * mod_env;
                    IGRushort    options;
                    IGRint               type;
                    IGRchar            * info;
                    IGRint               num_parents;
                    struct GRid        * parents;
                    IGRint               index; 
                    struct IGRplane    * dim_plane;
                    IGRdouble          * dim_plane_xaxis;
                    struct EMSgeomdata * dim_geom;
                    IGRint             * dim_type )
{
    IGRlong msg_loc, om_msg = OM_S_SUCCESS;

    *msg = msg_loc = EMS_S_Success;

    goto ret_end;
    
ret_end:

  EMWRAPUP (*msg, om_msg, "EMAelpsoid.EMdimparam");

  return (om_msg);
}

end implementation EMAelpsoid;
