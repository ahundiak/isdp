class implementation ECprims;

#include <alloca.h>
#include "msdef.h"
#include "grgs.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "comndef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "igrdef.h"
#include "igr.h"
#include "primco.h"

from GRlinear   import GRgetpolyline;
from GRvg       import GRgetsize, GRgetgeom;

extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRlinear_class_id;
extern OMuword OPP_GRconic_class_id;

IGRint ECget_curve_type ( msg, curve, type )
    IGRlong          * msg;
    struct GRlc_info * curve;
    IGRint           * type;
{
    IGRlong om_msg;
    OMuword classid;

    om_msg = om$get_classid ( objid = curve->located_obj.objid,
                              osnum = curve->located_obj.osnum,
                              p_classid = &classid );

    if (om$is_ancestry_valid (superclassid = OPP_GRcurve_class_id,    
                              subclassid = classid) == OM_S_SUCCESS)
    {
        if (om$is_ancestry_valid (superclassid = OPP_GRlinear_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            *type = IGRPY;
        }
        else if (om$is_ancestry_valid (superclassid = OPP_GRconic_class_id,
                                       subclassid = classid) == OM_S_SUCCESS)
        {
            *type = IGRAR;
        }
        else *type = IGRBC;
    }
    else *type = -1;

    return (om_msg);
}

IGRint DYprojection (msg, dynamics, info, num_events, events)
    IGRlong          * msg;
    IGRint             dynamics;
    IGRchar          * info;
    IGRint             num_events;
    struct GRevent   * events;
{
    IGRlong                 om_msg = OM_S_SUCCESS;
    IGRint                  i;
    IGRint                  type;
    IGRint                  action;
    struct GRid           * gr_id;
    struct GRmd_env       * mod_env;
    IGRint                  old_num_curves = 0;
    struct GRlc_info      * curves, * curve;
    IGRint                  num_curves = 0;
    struct GRid           * objects = NULL;
    struct DPele_header   * buffers = NULL;
    struct IGRdisplay       display;
    struct IGResbc          specific;

    *msg = MSSUCC;

    /*
     * Set up element specific display for bsplines.
     */
    specific.is_polydis = FALSE;
    specific.is_curvedis = TRUE;

    /*
     * Set up the display for the curves.
     */
    display.color = 2;
    display.weight = 0;
    display.style = 0;

    curve = &events[0].located_object[0];
    mod_env = &curve->module_info;

    /*
     * Get the leaf curves.
     */
    EMunwind_stupid_sets (curve,TRUE,TRUE,NULL_OBJID,&old_num_curves,&curves,msg);
    if (!old_num_curves || !(*msg & 1)) goto quit;

    buffers = (struct DPele_header *)alloca(old_num_curves * sizeof(struct DPele_header));
    objects = (struct GRid *)alloca(old_num_curves * sizeof(struct GRid));

    for (i=0; i<old_num_curves; ++i)
    {
        ECget_curve_type (msg, &curves[i], &type);

        gr_id = &curves[i].located_obj;

        switch (type)
        {
        case IGRPY:
        {
            struct IGRpolyline * polyline;

            polyline = (struct IGRpolyline *)alloca(sizeof(struct IGRpolyline));

            action = 0;
            om_msg = om$send ( msg = message GRlinear.GRgetpolyline
                                        ( msg,
                                          &mod_env->md_env.matrix_type,
                                          mod_env->md_env.matrix,
                                          &action,
                                          polyline ),
                               senderid = NULL_OBJID,
                               targetid = gr_id->objid,
                               targetos = gr_id->osnum );

            if (om_msg & *msg & 1)
            {
                polyline->points = (IGRdouble *)alloca(polyline->num_points * sizeof(IGRpoint));

                action = 1;
                om_msg = om$send ( msg = message GRlinear.GRgetpolyline
                                        ( msg,
                                          &mod_env->md_env.matrix_type,
                                          mod_env->md_env.matrix,
                                          &action,
                                          polyline ),
                               senderid = NULL_OBJID,
                               targetid = gr_id->objid,
                               targetos = gr_id->osnum );


                if (om_msg & *msg & 1)
                {
                    dp$build_dis_buffer ( buffer = &buffers[num_curves],
                                          type = IGRPY,
                                          display_att = &display,
                                          geometry = polyline );

                    objects[num_curves++] = *gr_id;
                }
            }
        }
            break;

        case IGRBC:
        case IGRAR:
        {
            struct IGRbsp_curve * bspline;
            IGRlong               size;

            om_msg = om$send ( msg = message GRvg.GRgetsize 
                                        ( msg,
                                          &mod_env->md_env.matrix_type,
                                          mod_env->md_env.matrix,
                                          &size ),
                               senderid = NULL_OBJID,
                               targetid = gr_id->objid,
                               targetos = gr_id->osnum );

            if (om_msg & *msg & 1)
            {
                bspline = (struct IGRbsp_curve *)alloca(size);

                om_msg = om$send ( msg = message GRvg.GRgetgeom
                                        ( msg,
                                          &mod_env->md_env.matrix_type,
                                          mod_env->md_env.matrix,
                                          (char *)bspline ),
                                   senderid = NULL_OBJID,
                                   targetid = gr_id->objid,
                                   targetos = gr_id->osnum );

                if (om_msg & *msg & 1)
                {
                    dp$build_dis_buffer ( buffer = &buffers[num_curves],
                                          type = IGRBC,
                                          display_att = &display,
                                          geometry = bspline,
                                          ele_spec_att = &specific );

                    objects[num_curves++] = *gr_id;
                }
            }
        }
            break;
        }
    }

    free (curves);

    switch (dynamics)
    {
    case EC_DY_EXTRUDE:
        om_msg = DYextrude ( msg,
                             info,
                             num_events,
                             events,
                             num_curves,
                             objects,
                             buffers );
        break;

    case EC_DY_START_ANGLE:
    case EC_DY_END_ANGLE:
        om_msg = DYturn ( msg,
                          info,
                          num_events,
                          events,
                          num_curves,
                          objects,
                          buffers );
        break;

    case EC_DY_CENTERLINE:
        om_msg = DYcenterline ( msg,
                                info,
                                num_events,
                                events,
                                num_curves,
                                objects,
                                buffers );
        break;
    }
    

quit:

    return (om_msg);
}

end implementation ECprims;

