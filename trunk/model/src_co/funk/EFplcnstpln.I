/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function creates a plane given one or more planar curves.
 If more that one curve is input then the 2nd, 3rd, 4th, etc.
 curves will be nested inside the first curve as alternating hole/area
 regions.  This implies that the first curve must be the outtermost boundary.

 It is assumed that input curves do not intersect each other.

 History

 04/4/91  : jhw : Create EFimpose_boundaries_on_plane function.
 06 Mar 1989 jBk Modified to do more complete message code
                checking and perform more precise deletion of the
                constructed object in case of failure.
 02/28/89 : SM  : Added NULL for curve_buffs argument to
                  EMSsurface.EMimpose_boundaries (New argument).
 08/08/88 : rlw : Removed logic from ECautoplanei.I and put it 
                  in this funciton.
 08/29/88 : rlw : Modified map options to accept bad curves
 06/16/91 : DLB : Mike Mathis added a parameter it EMimpose_boundary but
                  didnt change the send here so I fixed it.
 */

class implementation EMSplane;

%safe
#include <math.h>
%endsafe

#include "EMS.h"                /* Shared library stuff */
#include "ems_m_inc.h"          /* Includes everything */
#include "OMmacros.h"           /* OM_BLOCK_MOVE stuff */
#include "EC_P.h"               /* Message keys for prompt strings */
#include "EC_I.h"               /* Message keys for status strings */
#include "emsmapdef.h"          /* Impose boundary options */
#include "emsimpdef.h"          /* Impose boundary options */

extern OMuword OPP_EMSplane_class_id;

from EMSdpr import EMmake_primitive1;

IGRlong EFplace_nested_plane  ( number_of_curves,    /* Number of input curves */
                                curves,              /* Input curves */
                                construct_list,      /* Construction information for the surface */
                                want_status_messages,/* Should I tell the user where I am? */
                                my_stupid_id,        /* Caller's id */
                                constructed_object,  /* The surface */
                                msg )                /* Error return code */

    IGRlong         number_of_curves;
    struct          GRlc_info curves[];
    struct          GRvg_construct *construct_list;
    IGRboolean      want_status_messages;
    OM_S_OBJID      my_stupid_id;
    OM_S_OBJID      *constructed_object;
    IGRlong         *msg;
{
    OMuword        space_number;
    IGRlong        sts;
    struct         GRmd_env *md_env;
    IGRlong        EFimpose_boundaries_on_plane();

    /*
     * Initialize
     */
    *msg = MSSUCC;

    md_env = construct_list->env_info;
    space_number = md_env->md_id.osnum;
    *constructed_object = NULL_OBJID;

    /*
     * Without initialization of *constructed_object to NULL_OBJID,
     * it is possible to attempt to delete a random object in the
     * event of an error.
     */

    /*
     * Construct the surface
     */
    sts = om$construct ( classid =  OPP_EMSplane_class_id,
                         msg = message EMSplane.EMplane_of_curve 
                                      ( msg,
                                        construct_list,
                                        &curves[0],  /* Outtermost curve */
                                        NULL,        /* No curve by buffer */
                                        NULL,        /* No curve type */
                                        TRUE,        /* Test degeneracy */
                                        (number_of_curves == 1), /* Construct loopset */
                                        NULL,        /* No orientation information */
                                        NULL ),      /* Don't need edge information */
                         p_objid = constructed_object,
                         osnum = space_number );

    if (! (1 & sts & *msg & *construct_list->msg))
    {
        *constructed_object = NULL_OBJID;
        goto wrapup;
    }

    /*
     * Impose all the other curves as boundaries
     * on the constructed surface
     */
    if (number_of_curves > 1)
    {
        struct GRid plane;

        plane.objid = *constructed_object;
        plane.osnum = space_number;

        sts = EFimpose_boundaries_on_plane ( msg,
                                             construct_list->env_info,
                                             &plane,
                                             curves,
                                             number_of_curves,
                                             want_status_messages );

        if (!(1 & sts & *msg) ) goto wrapup;

    } /*  if (number_of_curves > 1) */

wrapup:

    if (!(1 & sts & *msg))
    {
        IGRlong      loc_msg;

        if (NOT IF_NULL_OBJID (*constructed_object))
        {
            om$send ( msg = message GRgraphics.GRdelete ( &loc_msg, md_env ),
                      senderid = my_stupid_id,
                      targetid = *constructed_object,
                      targetos = space_number );

            *constructed_object = NULL_OBJID;
        }

        return (FALSE);
    }

    return(TRUE);
}

IGRlong EFimpose_boundaries_on_plane ( msg,
                                       mod_env,
                                       plane,
                                       boundaries,
                                       num_boundaries,
                                       status_disp )
    IGRlong             * msg;
    struct GRmd_env     * mod_env;
    struct GRid         * plane;
    struct GRlc_info    * boundaries;
    IGRint                num_boundaries;
    IGRboolean            status_disp;
{
    IGRlong           om_msg;
    IGRushort map_options, imp_options;
    IGRlong           number_of_bad_points, number_of_bad_curves;
    IGRlong         * bad_curve_indices;
    IGRpoint        * bad_points;
    struct GRid       active_state, compressed_state;

    bad_curve_indices = NULL;

    imp_options = EMImpBnd_AutoNest |
                  EMImpBnd_NoStateTree;

    map_options = EMMapBnd_WantBadCurves |
                  EMMapBnd_NoStroke |
                  EMMapBnd_NoClip |
                  EMMapBnd_SurfIsPlane;

    if (status_disp) map_options |= EMMapBnd_WantStatMsg;

    om_msg = om$send ( msg = message EMSsurface.EMimpose_boundaries
                                  ( msg,
                                    num_boundaries,
                                    NULL,       
                                    boundaries, 
                                    NULL,       
                                    TRUE,       
                                    mod_env,
                                    &number_of_bad_points,
                                    &bad_points,
                                    &number_of_bad_curves,
                                    bad_curve_indices,
                                    NULL,  
                                    NULL,  
                                    NULL,  
                                    NULL,  
                                    map_options, 
                                    imp_options,
                                    NULL ),
                    senderid = NULL_OBJID,
                    targetid = plane->objid,
                    targetos = plane->osnum );

    if (number_of_bad_points && bad_points) free(bad_points);

    if (! (1 & om_msg & *msg)) goto wrapup;

wrapup:

    return (om_msg);
}

end implementation EMSplane;
