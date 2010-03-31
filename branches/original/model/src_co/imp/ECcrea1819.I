/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

04 Apr 1989 jBk In case the input curve is not a composite but
                still had a problem closing, I modified the code
                to check for OM_W_UNKNOWN_MSG.
13 Sep 1988 AIC Replaced explicit assignment of message to
                om$make_message.
17 Aug 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
*/

# include "EMS.h"

# ifndef DEBUG
# define DEBUG 0
# endif

# ifndef SHOWCALLS
# define SHOWCALLS 0
# endif

# if DEBUG || SHOWCALLS
#   include <stdio.h>
    extern int EFmsgReport ();
# endif

/* AND IS EMSokay EMSerror */
# include "EMSlogic.h"

/* EMS_W_Fail */
# include "EMSmsgdef.h"

/* IF_NULL_OBJID */
# include "OMmacros.h"

from GRowner import GRget_number_components;
from GRowner import GRget_components;
from GRconnector import GRflexconn, GRdisconn;
from GRgraphics import GRdelete;

method ECcreate1819 (
    EMSrc *rc;
    OMuword sClassid;
    struct GRid *surface;
    struct GRid *compcv;
    OM_p_MESSAGE creationMessage;
    struct GRmd_env *p_envInfo;
    struct GRid universalGroup;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup;
    struct GRid ruleArcGroup;
    struct GRid crossSectionGroup;
)
{
    EMSrc omrc = OM_S_SUCCESS, inputRc;
    int count = 1;
    int loopFailure = FALSE;
    int ii;

#   if SHOWCALLS

    static int staticNumCalls = 0;
    int numCalls;

    numCalls = ++staticNumCalls;
    (void)fprintf (stderr, "%d ECcrea1819.I into\n", numCalls);

#   endif

    surface->osnum = p_envInfo->md_id.osnum;
    inputRc = *rc;
    *rc = EMS_S_Success;

    /* if necessary, get components of firstBoundaryGroup */

    if (inputRc IS EMS_E_NoIntersection)
    {
        omrc = om$send (
            msg = message GRowner.GRget_number_components (
                (IGRlong *)rc,
                &count
            ),
            targetid = firstBoundaryGroup.objid,
            targetos = firstBoundaryGroup.osnum
        );

        if (omrc IS OM_W_UNKNOWN_MSG)
        {
            omrc = OM_S_SUCCESS;
            *rc = EMS_S_Success;
            count = 1;
        }
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = om$vla_set_dimension (
            varray = me->ids,
            size = count
        );

        if (inputRc ISNT EMS_E_NoIntersection AND EMSokay (omrc))
        {
            me->ids[0] = firstBoundaryGroup;
        }
    }

    if (inputRc IS EMS_E_NoIntersection OR inputRc IS EMS_E_Closed)
    {
        inputRc = EMS_W_Fail;
    }

    if (count > 1 AND EMSokay (omrc) AND EMSokay (*rc))
    {
        IGRint returnedCount;

        omrc = om$send (
            msg = message GRowner.GRget_components (
                (IGRlong *)rc,
                p_envInfo,
                me->ids,
                count,
                &returnedCount,
                0,
                OM_K_MAXINT
            ),
            targetid = firstBoundaryGroup.objid,
            targetos = firstBoundaryGroup.osnum
        );
    }

    if (EMSokay (omrc) AND EMSokay (*rc)) for (ii = 0; ii < count; ii++)
    {
        *compcv = me->ids[ii];

        omrc = om$construct (
            classid = sClassid,
            osnum = surface->osnum,
            msg = creationMessage,
            p_objid = &surface->objid
        );

        if (EMSerror (omrc) OR EMSerror (*rc))
        {
            loopFailure = TRUE;
        }
        else if (count > 1)
        {
            omrc = om$send (
                msg = message GRconnector.GRdisconn (
                    (IGRlong *)rc,
                    &firstBoundaryGroup
                ),
                targetid = compcv->objid,
                targetos = compcv->osnum
            );

            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                IGRlong flag = TRUE;
                IGRlong longii;

                longii = ii;

                omrc = om$send (
                    msg = message GRconnector.GRflexconn (
                        (IGRlong *)rc,
                        &flag,
                        &firstBoundaryGroup,
                        &longii,
                        &longii
                    ),
                    targetid = surface->objid,
                    targetos = surface->osnum
                );
            }

            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                EMSrc purom, purrc;

                purom = om$send (
                    msg = message GRgraphics.GRdelete (
                        (IGRlong *)&purrc,
                        p_envInfo
                    ),
                    targetid = compcv->objid,
                    targetos = compcv->osnum
                );
            }

            if (EMSerror (omrc) OR EMSerror (*rc))
            {
                /* group messed up */
                loopFailure = TRUE;
            }
        }
    }

    if (loopFailure) *rc = MSFAIL;

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
            p_envInfo
        );
*/

        GRdeleteArglist.msg = (IGRlong *)&delrc;
        GRdeleteArglist.md_env = p_envInfo;
        omrc = om$make_message(classname = "GRgraphics",
                               methodname = "GRdelete",
                               size = sizeof(GRdeleteArglist),
                               p_arglist = &GRdeleteArglist,
                               p_msg = &messageGRdelete);

        id[4] = firstBoundaryGroup;
        if (inputRc IS EMS_W_Fail)
        {
            /* input curve was not single composite curve */
            /* firstBoundaryGroup now a group of surfaces */
            id[4].objid = NULL_OBJID;
            *surface = firstBoundaryGroup;
        }
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
        *rc = EMS_W_Fail;
        if (inputRc ISNT EMS_W_Fail) *rc = MSSUCC;
    }
    else
    {
        omrc = OM_E_ABORT;
        *rc = EMS_W_Fail;
        if (inputRc ISNT EMS_W_Fail) *rc = MSFAIL;
    }

#   if SHOWCALLS
    {
        (void)fprintf (stderr, "%d ECcrea1819.I exit\n", numCalls);
    }
#   endif

    return omrc;
}

# if DEBUG
void ECcrea1819_PMS ()
{
    extern void OM_PMS ();

    OM_PMS ();
}
# endif

end implementation ECigdsiems;
