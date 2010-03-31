/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

13 Sep 1988 AIC Replaced explicit assignment of message to
                om$make_message.
01 Aug 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
Sudha   06/02/93        modified to include for BSprototype headers
*/

# include "EMS.h"

/* IF_NULL_OBJID */
# include "OMmacros.h"

/* BSrc BSERROR */
# include "bserr.h"

/* AND EMSokay */
# include "EMSlogic.h"

#include "bsdistptpt.h"

# define BASE   0
# define TOP    1

from GRowner import GRget_components;
from GRgraphics import GRdelete;
from GRcurve import GRcenter;
from GRcurve import GRendpts;
from EMScone import EMcone;

method EC1819rightCircularCone (
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
    IGRpoint centers[2];
    IGRpoint points[2];
    IGRdouble radii[2];
    struct GRid curve[2];
    IGRint index[2], ii = 1;

    /* get indices of desired curves */

    /* intentional block */
    {
        index[BASE] = 0;
        index[TOP] = (numSections - 1) * numCurvesPerBoundary;

        curve[BASE] = firstBoundaryGroup;
        curve[TOP] = boundaryGroup;
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

    /* get centers of curves */

    for (ii = 0; ii < 2 AND EMSokay (omrc) AND EMSokay (*rc); ii++)
    {
        omrc = om$send (
            msg = message GRcurve.GRcenter (
                (IGRlong *)rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix,
                centers[ii]
            ),
            targetid = curve[ii].objid,
            targetos = curve[ii].osnum
        );
    }

    /* get end points of curves */

    for (ii = 0; ii < 2 AND EMSokay (omrc) AND EMSokay (*rc); ii++)
    {
        IGRpoint dummypoint;

        omrc = om$send (
            msg = message GRcurve.GRendpts (
                (IGRlong *)rc,
                &list->env_info->md_env.matrix_type,
                list->env_info->md_env.matrix,
                points[ii],
                dummypoint
            ),
            targetid = curve[ii].objid,
            targetos = curve[ii].osnum
        );
    }

    /* derive radii of curves */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        BSrc bsrc;

        ii = 1;
        do
        {

            radii[ii] = BSdistptpt (
                &bsrc,
                points[ii],
                centers[ii]
            );
        } while (ii-- AND BSOKAY (bsrc));

        if (BSERROR (bsrc)) *rc = MSFAIL;
    }

    /* make cone */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        extern OMuword OPP_EMScone_class_id;

        surface->osnum = list->env_info->md_id.osnum;

        omrc = om$construct (
            classid = OPP_EMScone_class_id,
            msg = message EMScone.EMcone (
                rc,                 /* rc */
                list,               /* arglist */
                centers,            /* points */
                radii               /* radius */
            ),
            osnum = surface->osnum,
            p_objid = &surface->objid
        );
    }

    /* eliminate useless composite curve and graphic groups */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        EMSrc delrc;
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
        id[2] = boundaryGroup;
        id[1] = ruleArcGroup;
        id[0] = crossSectionGroup;

        do
        {
            if (NOT IF_NULL_OBJID (id[gg].objid))
            {
                (void)om$send (
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
        omrc = OM_S_SUCCESS;
        *rc = MSSUCC;
    }
    else
    {
        omrc = OM_E_ABORT;
        *rc = MSFAIL;
    }

    return omrc;
}

end implementation ECigdsiems;
