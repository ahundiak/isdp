/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

08/09/89    pp Should the generating curve be non-planar then project the
               same onto a least squares plane and use it instead.
28 Jul 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
Sudha   06/02/93        modified to include for BSprototype headers
*/

# include "EMS.h"

/* IF_NULL_OBJID */
# include "OMmacros.h"

/* BSrc BSERROR */
# include "bserr.h"

/* AND EMSokay */
# include "EMSlogic.h"

/* EMS_E_NoIntersection EMS_E_Closed EMS_W_Fail */
# include "EMSmsgdef.h"

#include "bsdistptpts.h"

from GRowner import GRget_components;
from GRcurve import GRendpts;
from EMSproject import EMplace_surface_of_projection;
from GRgraphics import GRdelete;
from GRvg import GRgeomprops;

# define CURVE      0
# define PJCURVE    1
# define START      0
# define END        1

method ECsurfaceOfProjection (
    EMSrc *rc;
    struct GRid universalGroup;
    IGRint numCurvesPerBoundary;
    IGRboolean oughtToClose;
    IGRint is_solid;
    IGRint numSections;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup;
    struct GRid ruleArcGroup;
    struct GRid crossSectionGroup;
    struct GRvg_construct *list;
    struct GRid *surface
)
{
    EMSrc omrc;
    IGRpoint point[2][2];
    struct GRid curve[2];
    IGRint index[2], ii = 1;
    IGRdouble mags[2];

    /* get indices of desired curves */


    /* intentional block */
    {
        index[CURVE] = 0;
        index[PJCURVE] = (numSections - 1) * numCurvesPerBoundary;

        curve[CURVE] = firstBoundaryGroup;
        curve[PJCURVE] = boundaryGroup;
    }

    /* get the curves */

    do
    {
        IGRint returnedCount;

        omrc = om$send (
            msg = message GRowner.GRget_components (
                (IGRlong *)rc,             /* msg */
                list->env_info, /* mod_env */
                &curve[ii],     /* objects */
                1,              /* number_objects */
                &returnedCount, /* count */
                index[ii],      /* from_obj */
                index[ii]       /* to_obj */
            ),
            targetid = curve[ii].objid,
            targetos = curve[ii].osnum
        );
    } while (ii-- AND EMSokay (omrc) AND EMSokay (*rc));

    /* get end points of curves */

    for (ii = 0; ii < 2 AND EMSokay (omrc) AND EMSokay (*rc); ii++)
    {
        omrc = om$send (
            msg = message GRcurve.GRendpts (
                (IGRlong *)rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix,
                point[ii][START],
                point[ii][END]
            ),
            targetid = curve[ii].objid,
            targetos = curve[ii].osnum
        );
    }

    /*
        I believe the vector of projection is the same as either
        the vector from the source curve's start point to the
        projected curve's start point or the vector from the
        source curve's start point to the projected curve's end
        point.  To choose, I reason that the vector with the
        lesser magnitude is the more direct, and thus the vector
        of projection.
    */

    /* get squared magnitudes of vectors */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        BSrc bsrc;
        int pp = 1;

        do
        {

            mags[pp] = BSdistptpts (
                &bsrc,
                point[CURVE][START],
                point[PJCURVE][pp]
            );
        } while (pp-- AND BSOKAY (bsrc));

        if (BSERROR (bsrc)) *rc = MSFAIL;
    }

    /* make one curve from firstBoundaryGroup */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = om$send (
            msg = message ECigdsiems.ECcomplexString (
                rc,                     /* rc */
                &firstBoundaryGroup,    /* element */
                numCurvesPerBoundary,   /* igdsCount */
                oughtToClose,           /* oughtClose; may not know */
                TRUE,                   /* tryToClose; why not? */
                list                    /* list */
            ),
            targetid = my_id
        );
       
        if (is_solid && EMSokay(omrc) && EMSokay(*rc))
        {
           struct GRprops propertiesStruct;

           omrc = om$send (
                msg = message GRvg.GRgeomprops (
                    (IGRlong *)rc,
                    &me->current_env.md_env.matrix_type,
                    me->current_env.md_env.matrix,
                    &propertiesStruct
                ),
                targetid = firstBoundaryGroup.objid,
                targetos = firstBoundaryGroup.osnum
            );

            if (EMSokay (omrc) AND EMSokay (*rc) AND
                propertiesStruct.phy_closed)
            {


/*
 * If the shape is not planar then project the same onto a least squares
 * plane.
 * pp (08/09/89)
 */
                if (!propertiesStruct.planar)
                {
                 struct IGRplane pln;
                 IGRpoint point_buff;
                 IGRvector normal_buff;
                 struct GRid pln_comp;
                 IGRint ii;

                 pln.point = &point_buff[0];
                 pln.normal = &normal_buff[0];

                 for (ii=0;ii<3;ii++)
                 {
                  pln.point[ii] = 0.0;
                  pln.normal[ii] = 0.0;
                 }

                 EFgenerate_least_squares_plane(rc,&firstBoundaryGroup,
                  &me->current_env,&pln);

                 if (1&*rc)
                 {
                  EFproject_any_curve_on_planen(rc,list,&firstBoundaryGroup,
                  &me->current_env,&pln,normal_buff,&pln_comp,NULL);
                
                  if (1&*rc)
                  {
                    omrc = om$send (
                       msg = message GRgraphics.GRdelete (
                           (IGRlong *)rc,
                           &me->current_env
                        ),
                       targetid = firstBoundaryGroup.objid,
                       targetos = firstBoundaryGroup.osnum
                   );
                   firstBoundaryGroup = pln_comp;
                  }
                 }
                }
/* end pp */
             }
        }
    }
   

    /* choose vector, and make surface of projection */

    if ((EMSokay (omrc) AND EMSokay (*rc)) OR
        (*rc IS EMS_E_NoIntersection OR *rc IS EMS_E_Closed))
    {
        IGRpoint *point2;
        extern OMuword OPP_EMSproject_class_id;
        struct GRid compcv;

        point2 = &point[PJCURVE][START];
        if (mags[END] < mags[START]) point2 = &point[PJCURVE][END];
        compcv = firstBoundaryGroup;

        omrc = om$send (
            msg = message ECigdsiems.ECcreate1819 (
                rc,
                OPP_EMSproject_class_id,
                surface,
                &compcv,
                message EMSproject.EMplace_surface_of_projection (
                    list                /* construct */,
                    &compcv             /* curve_id */,
                    list->env_info      /* curve_module_info */,
                    NULL                /* curve_geom */,
                    NULL                /* curve_type */,
                    point[CURVE][START] /* point1 */,
                    *point2              /* point2 */,
                    FALSE               /* pos_orient_flag */,
                    &surface->objid     /* new_objid */
                ),
                list->env_info,
                universalGroup,
                firstBoundaryGroup,
                boundaryGroup,
                ruleArcGroup,
                crossSectionGroup
            ),
            targetid = my_id
        );
    }

    /* polish returned message codes */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;
        *rc = MSSUCC;
    }
    else
    {
        omrc = OM_E_ABORT;
        if (*rc ISNT EMS_W_Fail) *rc = MSFAIL;
    }

    return omrc;
}

end implementation ECigdsiems;
