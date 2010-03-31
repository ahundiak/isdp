/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

12-Feb-93  Jack Changed om$send EMSgenbs.EMruled_surface to 
                EMSsubbs.EMruled_surface since message def. was
                moved.
04 Apr 1989 jBk Corrected a typographical error.  Apparently AIC
                forgot to put an important ampersand in front of
                messageGRdelete where it is actually sent to the
                leftover groups.
13 Sep 1988 AIC Replaced explicit assignment of message to
                om$make_message.
05 Aug 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
*/

# include "EMS.h"

# ifndef SHOWCALLS
# define SHOWCALLS 0
# endif

# if SHOWCALLS
#   include <stdio.h>
    extern int EFmsgReport ();
# endif

/* IF_NULL_OBJID */
# include "OMmacros.h"

/* ISNT EMSokay */
# include "EMSlogic.h"

from GRgraphics import GRdelete;
from EMSsubbs import EMruled_surface;
from GRcurve import GRendpts;

method ECconvolutedOrWarpedSurface (
    EMSrc *rc;
    struct GRid universalGroup;
    IGRint numCurvesPerBoundary;
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
    struct GRid *ccurve[2];
    IGRpoint curveEndPoints[2];
    struct GRlc_info cLCinfo[2];
    int ii = 1;

#   if SHOWCALLS

    static int staticNumCalls = 0;
    int numCalls;

    numCalls = ++staticNumCalls;
    (void)fprintf (stderr, "%d ECigdsWarp.I into\n", numCalls);

#   endif

    ccurve[0] = &firstBoundaryGroup;
    ccurve[1] = &boundaryGroup;

    if (numSections IS 1)
    {
        do
        {
            omrc = om$send (
                msg = message ECigdsiems.ECcomplexString (
                    rc                      /* rc */,
                    ccurve[ii]              /* element */,
                    numCurvesPerBoundary    /* igdsCount */,
                    FALSE                   /* oughtClose; do not know */,
                    TRUE                    /* tryToClose; why not? */,
                    list                    /* list */
                ),
                targetid = my_id
            );
        } while (ii-- AND EMSokay (omrc) AND EMSokay (*rc));
    }
    else
    {
        /*
            cannot work since this method is intended for type 18
            and type 19 surfaces and solids with just one section
        */

        *rc = MSINARG;
    }

    /* set curve GRlc_info structures, and */
    /* get end points of composite curves for use below */
    
    for (ii = 0; ii < 2 AND EMSokay (omrc) AND EMSokay (*rc); ii++)
    {
        IGRpoint dummyStartpoint;

        cLCinfo[ii].located_obj = *ccurve[ii];
        cLCinfo[ii].module_info = *list->env_info;
        cLCinfo[ii].proj_pnt[0] = 0.0;
        cLCinfo[ii].proj_pnt[1] = 0.0;
        cLCinfo[ii].proj_pnt[2] = 0.0;
        cLCinfo[ii].geom_parms.u = 0.0;
        cLCinfo[ii].geom_parms.v = 0.0;
        cLCinfo[ii].geom_parms.polygon_inx = 3;
        cLCinfo[ii].geom_parms.leaf_id.objid = NULL_OBJID;
        cLCinfo[ii].geom_parms.leaf_id.osnum = 0;

        omrc = om$send (
            msg = message GRcurve.GRendpts (
                (IGRlong *)rc,
                &cLCinfo[0].module_info.md_env.matrix_type,
                cLCinfo[0].module_info.md_env.matrix,
                dummyStartpoint,
                curveEndPoints[ii]
            ),
            targetid = ccurve[ii]->objid,
            targetos = ccurve[ii]->osnum
        );
    }

    /* construct ruled surface using composite curves */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        extern OMuword OPP_EMSgenbs_class_id;

        surface->osnum = cLCinfo[0].module_info.md_id.osnum;

        omrc = om$construct (
            classid = OPP_EMSgenbs_class_id,
            msg = message EMSsubbs.EMruled_surface (
                NULL            /* curve_1 */,
                &cLCinfo[0]     /* located_curve_1 */,
                NULL            /* curve_2 */,
                &cLCinfo[1]     /* located_curve_2 */,
                0               /* number_of_control_points */,
                NULL            /* curve_1_points */,
                NULL            /* curve_2_points */,
                curveEndPoints  /* curve_end_points */,
                TRUE            /* nat_side */,
                FALSE           /* reverse_curve_1 */,
                FALSE           /* reverse_curve_2 */,
                FALSE           /* not_used_1 */,
                FALSE           /* not_used_2 */,
                list            /* construct_list */,
                (IGRlong *)rc              /* msg */
            ),
            osnum = surface->osnum,
            p_objid = &surface->objid
        );
    }

    /* eliminate useless composite curve and graphic groups */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        EMSrc delomrc, delrc;
        OM_S_MESSAGE                    messageGRdelete;
        struct GRgraphics_GRdelete_Msg  GRdeleteArglist;
        struct GRid id[5];
        int gg = 4;

/*
        messageGRdelete = message GRgraphics.GRdelete (
            &delrc,
            list->env_info
        );
*/

        GRdeleteArglist.msg = (IGRlong *)&delrc;
        GRdeleteArglist.md_env = list->env_info;
        omrc = om$make_message(classname = "GRgraphics",
                               methodname = "GRdelete",
                               size = sizeof(GRdeleteArglist),
                               p_arglist = &GRdeleteArglist,
                               p_msg = &messageGRdelete);

        id[4] = firstBoundaryGroup; /* now a composite curve */
        id[3] = universalGroup;
        id[2] = boundaryGroup;      /* now a composite curve */
        id[1] = ruleArcGroup;
        id[0] = crossSectionGroup;

/*
        The universalGroup deletion ought to get them all, but it
        does not hurt to make certain.
*/

        do
        {
            if (NOT IF_NULL_OBJID (id[gg].objid))
            {
                delomrc = om$send (
                    msg = &messageGRdelete,
                    targetid = id[gg].objid,
                    targetos = id[gg].osnum
                );
            }
        } while (gg--);
    }

    /* polish returned message codes */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        *rc = MSSUCC;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *rc = MSFAIL;
        omrc = OM_E_ABORT;
    }

#   if SHOWCALLS
    {
        (void)fprintf (stderr, "%d ECigdsWarp.I exit\n", numCalls);
    }
#   endif

    return omrc;
}

end implementation ECigdsiems;
