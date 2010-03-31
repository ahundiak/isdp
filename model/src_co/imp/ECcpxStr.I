/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
ALGORITHM

Make the input graphic group into as few composite curves as
possible -- optimally one, and a closed one if requested.

NOTE

By using GRcompcurve.EMaddtocomp, I risk linking the incorrect
ends of a fledgeling composite curve and a subsequent addition. 
I wish I could specify that the order and flow are correct.  Then
I could do away with my GRcurve.GRendpts sends and my making up
search tolerances.

HISTORY

12 Mar 1992 mrm Fixed GRflexconn to properly send args by reference
04 Apr 1989 jBk Enhanced conditionally compiled debugging code.
06 Feb 1989 jBk Repaired typographical error in below-mentioned
                om$make_message -- it had introduced a new bug.
13 Sep 1988 AIC Replaced explicit assignment of message to
                om$make_message.
19 Jul 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
Sudha   06/02/93        modified to include for BSprototype headers
*/

# include "EMS.h"

# ifndef DEBUG
# define DEBUG 0
# endif

# if DEBUG
#   ifndef COUNTFAILURES
#   define COUNTFAILURES 1
#   endif
# endif

# ifndef SHOWCALLS
# define SHOWCALLS 0
# endif

# if SHOWCALLS
#   ifndef COUNTFAILURES
#   define COUNTFAILURES 1
#   endif
# endif

# ifndef COUNTFAILURES
# define COUNTFAILURES 0
# endif

# if DEBUG || SHOWCALLS || COUNTFAILURES
#   include <stdio.h>
    extern int EFmsgReport ();

#   ifndef AVAILPMS
#   define AVAILPMS 1
#   endif
# endif

# ifndef AVAILPMS
# define AVAILPMS 0
# endif

/* SOM_DIMENSION_OF SOM_SET_DIMENSION */
# include "OMmacros.h"

/* MAXFLOAT */
# include <values.h>

/* GRDGNLIMITS_MAX_I */
# include "godef.h"

/* BSEXTRACTPAR BSTOLLENVEC BSTOLCHRDHT */
# include "bsparameters.h"

/* BSERROR */
# include "bserr.h"

/* AND TRUE */
# include "EMSlogic.h"

/* EMS_S_Success EMS_E_NoIntersection EMS_E_Closed */
# include "EMSmsgdef.h"

#include <stdio.h>
#include "bsprintbspc.h"
#include "bsprintbsps.h"
#include "bsvalues.h"

from GRconnector import GRflexconn, GRdisconn;
from GRowner import GRget_number_components, GRget_components;
from GRowner import GRdelete_owner;
from GRgraphics import GRdelete;
from GRcompcurve import EMmakecomp, EMaddtocomp;

method ECcomplexString (
    EMSrc *rc;
    struct GRid *element;
    IGRshort igdsCount; /* currently unused */
    IGRboolean oughtClose;
    IGRboolean tryToClose;
    struct GRvg_construct *list
)
{
#   if COUNTFAILURES
    static staticNumCalls = 0;
    static countFailures = 0;
#   endif
    EMSrc omrc, localRc = EMS_S_Success;
    IGRdouble dist_tol, chrdht_tol;
    IGRint count;
    int index;
    struct GRlc_info initialcv;
    int madeOneCurve = FALSE;
    struct GRid compcv; /* returned curve; not necessarily composite */

#   if COUNTFAILURES || SHOWCALLS
    int numCalls;

    numCalls = ++staticNumCalls;
#   endif

#   if SHOWCALLS
    (void)fprintf (stderr, "%d ECcpxStr.I into\n", numCalls);
#   endif

    /* get the number of components in the graphic group */

    omrc = om$send (
        msg = message GRowner.GRget_number_components (
            (IGRlong *)rc,
            &count
        ),
        targetid = element->objid,
        targetos = element->osnum
    );

#   if COUNTFAILURES
        if (EMSerror (omrc) OR EMSerror (*rc))
        {
            (void)fprintf (stderr, "aa 0x%x 0x%x ", omrc, *rc);
        }
#   endif

    /* perhaps I ought test count versus idgscount. */

    /* allocate space for the ids of the components */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        if (count > om$dimension_of (varray = me->ids))
        {
            omrc = om$vla_set_dimension (
                varray = me->ids,
                size = count
            );

#           if COUNTFAILURES
                if (EMSerror (omrc) OR EMSerror (*rc))
                {
                    (void)fprintf (stderr, "bb 0x%x 0x%x ", omrc, *rc);
                }
#           endif
        }
    }

    /* get the components */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        IGRint returnedCount;

        omrc = om$send (
            msg = message GRowner.GRget_components (
                (IGRlong *)rc,
                list->env_info,
                me->ids,
                count,
                &returnedCount,
                0,
                OM_K_MAXINT
            ),
            targetid = element->objid,
            targetos = element->osnum
        );

#       if COUNTFAILURES
            if (EMSerror (omrc) OR EMSerror (*rc))
            {
                (void)fprintf (stderr, "cc 0x%x 0x%x ", omrc, *rc);
            }
#       endif

        if (returnedCount ISNT count)
        {
            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                *rc = MSFAIL;

#               if COUNTFAILURES
                if (EMSerror (omrc) OR EMSerror (*rc))
                {
                    (void)fprintf (stderr, "dd 0x%x 0x%x ", omrc, *rc);
                }
#               endif
            }
        }
    }

    /* get tolerance for curve connection */

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        BSrc bsrc;

        BSEXTRACTPAR (&bsrc, BSTOLLENVEC, dist_tol);

        if (tryToClose AND BSOKAY (bsrc))
        {
            BSEXTRACTPAR (&bsrc, BSTOLCHRDHT, chrdht_tol);
        }

        if (BSERROR (bsrc))
        {
            *rc = MSFAIL;
        }

#       if COUNTFAILURES
            if (EMSerror (omrc) OR EMSerror (*rc))
            {
                (void)fprintf (stderr, "ee 0x%x 0x%x ", omrc, *rc);
            }
#       endif
    }

    /* disconnect curves from graphic group */

    /* intentional block */
    {
        OM_S_MESSAGE                        disconnMessage;
        struct GRconnector_GRdisconn_Msg    disconnArglist;

/*
        disconnMessage = message GRconnector.GRdisconn (
            rc,
            element
        );
*/

        disconnArglist.msg = (IGRlong *)rc;
        disconnArglist.owners_id = element;
        omrc = om$make_message(classname = "GRconnector",
                               methodname = "GRdisconn",
                               size = sizeof(disconnArglist),
                               p_arglist = &disconnArglist,
                               p_msg = &disconnMessage);

        for (index = 0;
            EMSokay (omrc) AND EMSokay (*rc) AND index < count;
            index++
        )
        {
            omrc = om$send (
                msg = &disconnMessage,
                targetid = me->ids[index].objid,
                targetos = me->ids[index].osnum
            );

#           if COUNTFAILURES
                if (EMSerror (omrc) OR EMSerror (*rc))
                {
                    (void)fprintf (stderr, "ff %d 0x%x 0x%x ",
                        index, omrc, *rc);
                }
#           endif
        }
    }

    /* initialize initializable parts of initialcv */

    initialcv.module_info = *list->env_info;
    initialcv.proj_pnt[0] = 0.0;
    initialcv.proj_pnt[1] = 0.0;
    initialcv.proj_pnt[2] = 0.0;
    initialcv.geom_parms.u = 0.0;
    initialcv.geom_parms.v = 0.0;
    initialcv.geom_parms.polygon_inx = 3;
    initialcv.geom_parms.leaf_id.objid = NULL_OBJID;
    initialcv.geom_parms.leaf_id.osnum = list->env_info->md_id.osnum;

    index = 0;

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        /* okay to return soul input or make composite curve */

        if (count IS 1)
        {
            compcv = me->ids[0]; /* set returned curve */
            madeOneCurve = TRUE;
        }
        else while (index < count)
        {
            /* try to put current curve into composite */

            if (index IS count - 1)
            {
                /*
                    then this curve was to be the last curve in a
                    composite curve, but it failed to connect;
                    skip over everything here and just add it to
                    the graphic group
                */

                compcv = me->ids[index++];
            }
            else /* okay to begin making composite curve */
            {
                extern OMuword OPP_GRcompcurve_class_id;
                int initialCvIndex;
                IGRlong comp_so_far = 1;
                int rotten;

                /* start the composite curve */

                compcv.osnum = list->env_info->md_id.osnum;
                initialcv.located_obj = me->ids[index];
                initialCvIndex = index;

                omrc = om$construct (
                    msg = message GRcompcurve.EMmakecomp (
                        (IGRlong *)rc,
                        &initialcv.module_info,
                        (IGRlong)1,             /* num_ent */
                        &initialcv,             /* entries */
                        (IGRlong *)&rotten
                    ),
                    classid = OPP_GRcompcurve_class_id,
                    osnum = compcv.osnum,
                    p_objid = &compcv.objid
                );

#               if COUNTFAILURES
                    if (EMSerror (omrc) OR EMSerror (*rc))
                    {
                        (void)fprintf (stderr, "gg %d %d 0x%x 0x%x ",
                            index, count, omrc, *rc);
                    }
#               endif

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    /*
                        advance to next curve and try to link all the rest
                    */

                    index++;

                    while (EMSokay (omrc) AND EMSokay (*rc) AND
                        index < count)
                    {
                        IGRpoint comp_start, comp_end;

                        omrc = om$send (
                            msg = message GRcompcurve.EMaddtocomp (
                                (IGRlong *)rc,
                                me->ids[index],
                                &initialcv.module_info,
                                &initialcv.module_info,
                                TRUE,       /* inter_allowed */
                                MAXFLOAT,   /* search_tol */
                                dist_tol,   /* connect_tol */
                                FALSE,      /* valid_end_pnt */
                                comp_start,
                                comp_end,
                                &comp_so_far
                            ),
                            targetid = compcv.objid,
                            targetos = compcv.osnum
                        );

#                       if COUNTFAILURES
                            if (EMSerror (omrc) OR EMSerror (*rc))
                            {
                                (void)fprintf (stderr,
                                    "hh %d %d 0x%x 0x%x ",
                                    index, count, omrc, *rc);
                            }
#                       endif

                        if (EMSokay (omrc) AND EMSokay (*rc))
                        {
                            index++;
                        }
                        else
                        {
                            localRc = EMS_E_NoIntersection;
                        }
                    } /* end attempted iteration over rest of list */
                } /* end if EMmakecomp worked */

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    /* if success is in the air after the iterations */

                    if (initialCvIndex IS 0 AND index IS count)
                    {
                        /* made one composite from all input */
                        madeOneCurve = TRUE;

                        if (oughtClose)
                        {
                            /* the element is supposed to be closed */
                            extern IGRlong EMclose_composite ();

                            omrc = EMclose_composite (
                                (IGRlong *)rc,
                                list->env_info,
                                compcv,
                                (IGRdouble)GRDGNLIMITS_MAX_I,
                                dist_tol
                            );
                        }
                        else if (tryToClose)
                        {
                            /* the element might close; try it */
                            extern IGRlong EMclose_composite ();

                            omrc = EMclose_composite (
                                (IGRlong *)rc,
                                list->env_info,
                                compcv,
                                chrdht_tol,
                                dist_tol
                            );
                        }

                        if (EMSerror (omrc) OR EMSerror (*rc))
                        {
                            localRc = EMS_E_Closed;

#                           if COUNTFAILURES
                                (void)fprintf (stderr,
                                    "ii %d %d 0x%x 0x%x ",
                                    oughtClose, tryToClose , omrc, *rc);
#                           endif
                        }
                    } /* end if made one composite from all input */
                } /* end "success is in the air" clause */
                else /* something wrong detected after the iterations */
                {
                    if (index IS initialCvIndex)
                    {
                        /*
                            not even the first curve got in compcv!
                            reconnect current (first) curve to group;
                            increment index to start over with next
                            curve; by calling the current curve
                            "compcv", we can reuse the code below for
                            connecting a partial result to the
                            graphic group
                        */

                        compcv = me->ids[index++];
                    }
                    else if (index IS initialCvIndex + 1)
                    {
                        /*
                            only the initial curve got in compcv;
                            remove the composite; leave the bare
                            curve for connection to graphic
                            group; allow current curve to be
                            start of try for another composite
                            curve
                        */                
                        EMSrc disconnrc, disconnomrc;

                        disconnomrc = om$send (
                            msg = message GRowner.GRdelete_owner (
                                (IGRlong *)&disconnrc,
                                list->env_info
                            ),
                            targetid = compcv.objid,
                            targetos = compcv.osnum
                        );

#                       if COUNTFAILURES
                        if (EMSerror (disconnomrc) OR
                            EMSerror (disconnrc))
                        {
                            (void)fprintf (stderr, "jj %d 0x%x 0x%x ",
                                index , disconnomrc, disconnrc);
                        }
#                       endif

                        if (EMSokay (disconnomrc) AND EMSokay (disconnrc))
                        {
                            /*
                                now that the composite header has
                                been deleted, simply connect the
                                first curve to the graphic group
                            */

                            compcv = me->ids[initialCvIndex];
                        }
                    } /* end else if (index IS initialCvIndex + 1) */
                } /* end else something wrong found after iterations */
            } /* end else okay to begin making composite curve */

            if (NOT madeOneCurve)
            {
                /* put whatever is in compcv in the graphic group */
                IGRlong flag = TRUE;
                IGRlong index = OM_K_MAXINT;

                omrc = om$send (
                    msg = message GRconnector.GRflexconn (
                        (IGRlong *)rc,
                        &flag,
                        element,    /* graphic group at this point */
                        &index,
                        &index
                    ),
                    targetid = compcv.objid,
                    targetos = compcv.osnum
                );

#               if COUNTFAILURES
                    if (EMSerror (omrc) OR EMSerror (*rc))
                    {
                        (void)fprintf (stderr, "ll %d 0x%x 0x%x ",
                            index , omrc, *rc);
                    }
#               endif
            }
        } /* end while try to put current curve into composite */
    } /* fi okay to return soul input or make composite curve */

    /* clean up graphic group and returned message codes */

    if (madeOneCurve)
    {
        /*
            was only one curve in group or made one composite
            from all input
        */ 
        EMSrc delrc;

        (void)om$send (
            msg = message GRgraphics.GRdelete (
                (IGRlong *)&delrc,
                &initialcv.module_info
            ),
            targetid = element->objid,
            targetos = element->osnum
        );

        *element = compcv;
    }

    if (madeOneCurve AND EMSokay (omrc) AND EMSokay (*rc))
    {
        *rc = MSSUCC;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        if (localRc ISNT EMS_S_Success)
            *rc = localRc;
        else
            *rc = MSFAIL;

        omrc = OM_E_ABORT;
    }

#   if COUNTFAILURES
    if (EMSerror (omrc) OR EMSerror (*rc))
    {
        (void)fprintf (stderr, "%d ECcpxStr.I failure is %d ",
            numCalls, ++countFailures);
    }
#   endif

#   if SHOWCALLS
    {
        (void)fprintf (stderr, "%d ECcpxStr.I exit\n", numCalls);
    }
#   endif

    return omrc;
}

# if AVAILPMS

void ECcpxStr_PMS ()
{
    extern void OM_PMS ();

    OM_PMS ();

    return;
}

void ECcpxStr_BSprintbspc (cv)
struct IGRbsp_curve *cv;
{

    (void)BSprintbspc (stderr, NULL, cv, FALSE);

    return;
}

void ECcpxStr_BSprintbsps (sf)
struct IGRbsp_surface *sf;
{

    (void)BSprintbsps (stderr, NULL, sf, FALSE);

    return;
}

# endif /* AVAILPMS */

end implementation ECigdsiems;
