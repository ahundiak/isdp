class implementation ECprims;

/*
  HISTORY

Sudha	07/05/93	Modified for BSprototypes ansification

*/

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
#include "marang2vc.h"
#include "maptplpro.h"

extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRpoint_class_id;
extern OMuword OPP_GRcmpowner_class_id;
extern OMuword OPP_SKmgr_class_id;

from GRvg   import GRdetplane;

IGRint EFget_solids_and_holes ( msg,
                                curve,
                                mod_env,
                                curves,
                                solids,
                                num_solids,
                                holes,
                                holes_solid,
                                num_holes )
    IGRlong         * msg;
    struct GRid     * curve;
    struct GRmd_end * mod_env;
    GRobjid        ** curves;
    GRobjid        ** solids;
    IGRint          * num_solids;
    GRobjid        ** holes;
    GRobjid        ** holes_solid;
    IGRint          * num_holes;
{
    IGRint          i, j;
    OMuint          count;
    OMuword         classid;
    OM_S_CHANSELECT chansel;
    
    *msg = MSSUCC;

    *num_solids = *num_holes = 0;
    *curves = *solids = *holes = *holes_solid = NULL;

    om$get_classid ( objid = curve->objid,
                     osnum = curve->osnum,
                     p_classid = &classid );

    if ( om$is_ancestry_valid ( superclassid = OPP_SKmgr_class_id,
                                subclassid = classid ) == OM_S_SUCCESS )
    {
        OMuword   osnum;
        GRobjid * objects;
        IGRint    num_objects;

        GRget_to_comp_chansel (&chansel);

        om$get_channel_count ( osnum = curve->osnum,
                               objid = curve->objid,
                               p_chanselect = &chansel,
                               count = &count );

        objects = (GRobjid *)alloca(count * sizeof(GRobjid));
        
        for (i=0, num_objects = 0; i<count; ++i)
        {
            om$get_objid_at_index ( osnum = curve->osnum,
                                    objid = curve->objid,
                                    p_chanselect = &chansel,
                                    index = i,
                                    objidaddr = &objects[num_objects],
                                    osnumaddr = &osnum );

            om$get_classid ( osnum = osnum,
                             objid = objects[num_objects],
                             p_classid = &classid );

            if (om$is_ancestry_valid ( superclassid = OPP_GRpoint_class_id,
                                       subclassid = classid ) != OM_S_SUCCESS)
            {
                ++num_objects;
            }
        }

        /*
         * KLUDGE FOR DEMO!!!!
         */
        if (num_objects)
        {
            *num_solids = 1;
            *solids = *curves = (GRobjid *)malloc(2 * num_objects * sizeof(GRobjid));
            (*solids)[0] = objects[0];

            if (num_objects > 1)
            {
                *num_holes = num_objects - 1;
                *holes = *curves + *num_solids;
                *holes_solid = *holes + *num_holes;

                for (i=1,j=0; i<num_objects; ++i,++j)
                {
                    (*holes)[j] = objects[i];
                    (*holes_solid)[j] = (*solids)[0];
                }
            }
        }
    }
    else if (om$is_ancestry_valid (superclassid = OPP_GRcurve_class_id,
                                   subclassid = classid) == OM_S_SUCCESS)
    {
        *num_solids = 1;
        *curves = *solids = (GRobjid *)malloc(sizeof(GRobjid));
        (*curves)[0] = curve->objid;
    }
    else *msg = MSFAIL;

    return (*msg);
}

IGRint EFunweight_weight_buffers (buffers, num_buffers, is_weight)
    struct DPele_header * buffers;
    IGRint                num_buffers;
    IGRboolean            is_weight;
{
    IGRint                i, j;
    IGRdouble           * p_pole, weight;
    struct IGRbsp_curve * bspcurve;

    for (i=0; i<num_buffers; ++i)
    {
        if (buffers[i].type == IGRBC)
        {
            bspcurve = buffers[i].geometry.bspcurve;

            if (bspcurve->rational)
            {
                p_pole = bspcurve->poles;

                for (j=0; j<bspcurve->num_poles; ++j)
                {
                    if ((weight = bspcurve->weights[j]) != 1.0)
                    {
                        if (is_weight)
                        {
                            p_pole[0] *= weight;
                            p_pole[1] *= weight;
                            p_pole[2] *= weight;
                        }
                        else
                        {
                            p_pole[0] /= weight;
                            p_pole[1] /= weight;
                            p_pole[2] /= weight;
                        }
                    }

                    p_pole += 3;
                }
            }
        }
    }

    return (1);
}

EFget_turn_angle (msg, point, plane, start_vec, angle)
    IGRlong         * msg;
    IGRdouble       * point;
    struct IGRplane * plane;
    IGRdouble       * start_vec;
    IGRdouble       * angle;
{
    IGRdouble   loc_angle[3], proj[3], end_vec[3];

    /*
     * Project the to point onto the plane defined by the centerline.
     */
    MAptplproj (msg, (IGRpoint *)point, plane, proj);

    if (*msg & 1)
    {
        /*
         * Determine the end vector.
         */
        end_vec[0] = proj[0] - plane->point[0];
        end_vec[1] = proj[1] - plane->point[1];
        end_vec[2] = proj[2] - plane->point[2];

        /*
         * Get the angle between the start vector and the end vector.
         */
        MArang2vc (msg, start_vec, end_vec, plane->normal, loc_angle);

        if (*msg & 1) *angle = loc_angle[0];
    }

    return (*msg & 1);    
}

IGRint EFdetermine_plane (msg, mod_env, curve, plane)
    IGRlong             * msg;
    struct GRmd_env     * mod_env;
    struct GRid         * curve;
    struct IGRplane     * plane;
{
    IGRlong         om_msg;
    IGRint          i;

    *msg = MSSUCC;

    om_msg = om$send ( msg = message GRvg.GRdetplane
                                            ( msg,
                                              &mod_env->md_env.matrix_type,
                                              mod_env->md_env.matrix,
                                              plane ),
                       senderid = NULL_OBJID,
                       targetid = curve->objid,
                       targetos = curve->osnum );

    if (!(om_msg & *msg & 1))
    {
        OMuint          count;
        OMuword         classid;
        OM_S_CHANSELECT chansel;
    
        om$get_classid ( objid = curve->objid, 
                         osnum = curve->osnum,
                         p_classid = &classid );

        if ( om$is_ancestry_valid ( superclassid = OPP_GRcmpowner_class_id,
                                    subclassid = classid ) == OM_S_SUCCESS )
        {
            OMuword   osnum;
            GRobjid   object;

            GRget_to_comp_chansel (&chansel);

            om$get_channel_count ( osnum = curve->osnum,
                                   objid = curve->objid,
                                   p_chanselect = &chansel,
                                   count = &count );

            for (i=0; i<count; ++i)
            {
                om$get_objid_at_index ( osnum = curve->osnum,
                                        objid = curve->objid,
                                        p_chanselect = &chansel,
                                        index = i,
                                        objidaddr = &object,
                                        osnumaddr = &osnum );

                om_msg = om$send ( msg = message GRvg.GRdetplane
                                                ( msg,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  plane ),
                               senderid = NULL_OBJID,
                               targetid = object,
                               targetos = osnum );

                if (om_msg & *msg & 1) break;
            }
        }
        else *msg = MSFAIL;
    }

    *msg = (om_msg & *msg & 1) ? MSSUCC : MSFAIL;

    return (OM_S_SUCCESS);
}

end implementation ECprims;

