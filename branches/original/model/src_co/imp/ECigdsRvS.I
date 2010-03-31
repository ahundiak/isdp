/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

12/01/89    RC Modified the logic to calculate the axis of revolution.
08/09/89    pp Should the generating curve be non-planar then project the
               same onto a least squares plane and use it instead.
28 Jul 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
Sudha   06/02/93        modified to include for BSprototype headers
*/

# include "EMS.h"

/* M_PI */
# include <values.h>

/* IF_NULL_OBJID */
# include "OMmacros.h"

/* BSrc BSERROR */
# include "bserr.h"

/* AND EMSokay */
# include "EMSlogic.h"

/* EMS_E_NoIntersection EMS_E_Closed EMS_W_Fail */
# include "EMSmsgdef.h"

#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

# define angle_tol (0.1)

from GRowner import GRget_components;
from EMSrevol import EMrevolve_curve;
from GRgraphics import GRdelete;
from GRgraphics import GRgetrang, GRcopy;
from GRvg import GRdetplane, EMptatpr;
from GRcurve import GRendpts;
from GRcurve import GRcenter;
from GRconic import GRgetarc;
from GRvg import GRgeomprops;

method ECsurfaceOfRevolution (
    EMSrc *rc1;
    struct GRid universalGroup;
    IGRint numCurvesPerBoundary;
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
    IGRlong *rc;
    IGRpoint axis[2];
    IGRdouble sweepangle, sweepangle_360;
    IGRvector cross_p;
    struct GRid arc;
    struct IGRarc arcpara;
    int ii;
    GRrange range;          /* range box of rule arc group */
    IGRdouble srarange;     /* distance between range box points */
    BSrc bsrc;

    rc=(IGRlong *)rc1;
    /* get range of rule arc group */

    /* intentional block */
    {
        IGRboolean worldrange = TRUE;

        omrc = om$send (
            msg = message GRgraphics.GRgetrang (
                rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix,
                &worldrange,
                range
            ),
            targetid = ruleArcGroup.objid,
            targetos = ruleArcGroup.osnum
        );
    }

    /* get cross product tolerance, and */
    /* calculate distance between range box points */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {

        srarange = BSdistptpt (&bsrc, range, &range[3]);

        if (BSERROR (bsrc)) *rc = MSFAIL;
        else srarange *= .005;
    }

    /* get arc with diameter of more than 0.5% of range */

    for (ii = 0, arcpara.prim_axis = -47;
        EMSokay (omrc) AND EMSokay (*rc) AND arcpara.prim_axis < srarange;
        ii++)
    {
        /* get arc */

        /* intentional block */
        {
            IGRint returnedCount;

            omrc = om$send (
                msg = message GRowner.GRget_components (
                    rc,             /* msg */
                    list->env_info, /* mod_env */
                    &arc,           /* objects */
                    1,              /* number_objects */
                    &returnedCount, /* count */
                    ii,             /* from_obj */
                    ii              /* to_obj */
                ),
                targetid = ruleArcGroup.objid,
                targetos = ruleArcGroup.osnum
            );
        }

        /* get parametric data for arc */

        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            omrc = om$send (
                msg = message GRconic.GRgetarc (
                    rc,
                    &list->env_info->md_env.matrix_type,
                    list->env_info->md_env.matrix,
                    &arcpara
                ),
                targetid = arc.objid,
                targetos = arc.osnum
            );
        }
    }
    /* done get arc with radius of more than 1% of range */

    /* get plane of arc */
/*
    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        IGRpoint point;
        struct IGRplane planepara;

        planepara.point = point;
        planepara.normal = normal;

        omrc = om$send (
            msg = message GRvg.GRdetplane (
                rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix,
                &planepara
            ),
            targetid = arc.objid,
            targetos = arc.osnum
        );
    }
*/

    /* get center of arc */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = om$send (
            msg = message GRcurve.GRcenter (
                rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix,
                axis[0]
            ),
            targetid = arc.objid,
            targetos = arc.osnum
        );
    }

    /*
     * Since the plane's (plane encompassing the curve) normal 
     * is arbitrary and does not always 
     * confirm to the curve's flow direction, the following logic
     * is used to compute the axis of revolution. -- RC  12/01/89
     */

    {
     IGRvector vec1, vec2;
     IGRdouble par1, par2;

     par1 = 0.;
     sweepangle = arcpara.sweep_angle * 180.0 / M_PI;
     if (sweepangle <= 90.) par2 = 1.0;
     else 
     {
      if (sweepangle <= 180.) par2 = 0.5125;
      else par2 = 0.343;
     }

      omrc = om$send ( msg = message GRvg.EMptatpr ( rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix, &par1, 1, vec1),
               targetid = arc.objid,
               targetos = arc.osnum );
      
      omrc = om$send ( msg = message GRvg.EMptatpr ( rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix, &par2, 1, vec2),
               targetid = arc.objid,
               targetos = arc.osnum );
      
      for (ii= 0; ii < 3; ii++)
      {
       vec1[ii] -= axis[0][ii];
       vec2[ii] -= axis[0][ii];
      }
  
      BScrossp (&bsrc, vec1, vec2, cross_p);
      BSnorvec (&bsrc, cross_p);

           
    }
 
    /* make one curve from firstBoundaryGroup */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = om$send (
            msg = message ECigdsiems.ECcomplexString (
                (EMSrc *)rc,                     /* rc */
                &firstBoundaryGroup,    /* element */
                numCurvesPerBoundary,   /* igdsCount */
                FALSE,                  /* oughtClose; do not know */
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
                    rc,
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
                           rc,
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

    /* make derivations, and make surface of projection */

    if ((EMSokay (omrc) AND EMSokay (*rc)) OR
        (*rc IS EMS_E_NoIntersection OR *rc IS EMS_E_Closed))
    {
        int circle = FALSE;
        extern OMuword OPP_EMSrevol_class_id;
        struct GRlc_info cLCinfo;

        /*
            change angle sweep angle in radians of one section to
            sweep angle in degrees of all sections
        */
        sweepangle = numSections * arcpara.sweep_angle * 180.0 / M_PI;
        sweepangle_360 = sweepangle - 360.0;
        if (sweepangle_360 < 0.0) sweepangle_360 = -sweepangle_360;
        if (sweepangle_360 < angle_tol)
        {
            sweepangle = 360.0;
            circle = TRUE;
        }

        ii = 2;
        do
        {
            axis[1][ii] = axis[0][ii] + cross_p[ii];
            cLCinfo.proj_pnt[ii] = 0;
        } while (ii--);

        cLCinfo.located_obj = firstBoundaryGroup;
        cLCinfo.module_info = *list->env_info;

        cLCinfo.geom_parms.u = 0;
        cLCinfo.geom_parms.v = 0;
        cLCinfo.geom_parms.polygon_inx = 0;
        cLCinfo.geom_parms.leaf_id.objid = NULL_OBJID;
        cLCinfo.geom_parms.leaf_id.osnum = cLCinfo.located_obj.osnum;

        omrc = om$send (
            msg = message ECigdsiems.ECcreate1819 (
                (EMSrc *)rc,
                OPP_EMSrevol_class_id,
                surface,
                &cLCinfo.located_obj,
                message EMSrevol.EMrevolve_curve (
                    list            /* construct_list */,
                    &cLCinfo        /* curve_info */,
                    NULL            /* curve */,
                    axis            /* axis_line */,
                    0.0             /* start_angle */,
                    sweepangle      /* sweep_angle */,
                    circle          /* is_full_revolution */,
                    FALSE           /* pos_orient_flag */,
                    &surface->objid /* new_objid */,
                    (IGRint *)rc              /* msg */
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
