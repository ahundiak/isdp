/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgencompsf;

#include "EMS.h"
#include "bserr.h"
#include "bscvtstclsd.h"
#include "bscvcoplan.h"
#include "bsprintbspc.h"

/*
ALGORITHM

for each of the two input surfaces
do
    if its loopset exists
        if its loopset is natural
            get the edges
        else
            this surface is ineligible
        fi
    else
        send a make natural boundary message to the surface,
            getting the resultant edges
    fi
done

for each pair of edges which has at least one non-degenerate edge
do
    get the model space equivalant curves of the edges and
        construct a surface between the pair of curves
    send a make natural boundary message to the resultant surface
        (the make composite surface message requires a loopset on
        each surface)
done

send self make composite surface message; could be optimized
    here since we know the arrangement; could also orient the
    surfaces before calling since we have a pretty good idea how
    they ought to be

HISTORY

Sudha      06/21/93     Modified to handle BSprototype ansification

12-Feb-93  Jack Changed om$send EMSgenbs.EMruled_surface to 
                EMSsubbs.EMruled_surface since message def.
                was moved.
13 Jul 1988 jBk Changed name of message implemented from
                EMmk_w_natural_sides_twixt_2sf to
                EMmkWNatSidesTw2S.
                Changed arguments and code to eliminate numParts
                and to change parts from an array of six to a
                singleton which may contain a graphic group of
                unconnected parts in the event of failure.
                Made fix in error-case creation of graphic group.
20 Jun 1988 jBk To compensate for rejected messages (GRgetsize
                and GRgetgeom) no longer being overridden at
                EMSsfimpbnd, I now give a NULL pointer as the
                pointer to the surface id when sending the
                EMget_bcxyz_geom message to an edge.
07 Jun 1988 jBk REWRITTEN to get, and process efficiently, more
                than four edges from a surface.  Stated algorithm
                is only a fair approximation of what goes on.
06 Jun 1988 jBk Initialize failure to be FALSE.
                Changed loopset test not to test for loopset of
                surfaces other than those of subclasses of
                EMSsubbs.  Also do not test for natural loopset.
19 May 1988 jBk Modified message code assignment and reporting.
                Added capability to detect pairs of closed,
                coplanar, connectable edges and construct planes
                (instead of general surfaces) accordingly.
12 May 1988 jBk By commenting, excluded code to check for
                degeneracy of edges, since connectable edges are
                not supposed to be degenerate.
                Now return EMS_E_CompositeFailed for failure to
                make composite of natural sides and input
                surfaces.
11 May 1988 jBk Modified to use only connectable edges.
                Delete created sides for which natural boundaries
                cannot be created.  Fixed mistakenly assigned
                pointer.
                Fixed type mismatch (not found by cc!) of using
                GRobjid array instead of GRid array for getting
                edges.
05 Apr 1988 jBk Initialize each temporary curve's bdrys pointer
                to be NULL.
                Also modified to pass curveEndPoints in
                EMruled_surface message.  This causes the
                recipient to make incompatible curves compatible.
28 Jan 1988 jBk Genesis.
*/

# ifndef DEBUG
# define DEBUG 0
# endif

# ifndef DEBUGGEOM
# define DEBUGGEOM 0
# endif

# ifndef BADMAKECOMP
# define BADMAKECOMP 0
# endif

/* fprintf, stderr */
# if DEBUG
# include <stdio.h>
# endif

# if DEBUG

#   define DEBUG_EMSmsgReport(code, string) \
        EMSmsgReport (code, string, TRUE)

#   define DEBUG_fprintf(fp, fmt, var) fprintf ((fp), (fmt), (var))
#   define DEBUG_okay(fp) fprintf \
        (fp, "%s on line %d\n", okay ? "okay" : "bad", __LINE__)

#   omdef DEBUG_memory(fp)
    {
        char *ptr;

        DEBUG_fprintf (fp, "debug memory on line %d\n", __LINE__);
        ptr = om$malloc (size = (unsigned)1);
        if (ptr) om$dealloc (ptr = ptr);
    }
#   endomdef

#   if DEBUGGEOM

#       define DEBUG_BSprintbspc(cvAddr)                    \
            ((cvAddr)->poles ?                              \
                BSprintbspc (stderr, "", (cvAddr), FALSE) : \
                TRUE                                        \
            )

#       omdef DEBUG_send (objid)
            om$send (
                msg = message Root.debug (),
                targetid = (objid)
            )
#       endomdef

#   else
#       define DEBUG_BSprintbspc(x)
#       define DEBUG_send(objid) 
#   endif

# else
#   define DEBUG_EMSmsgReport(code, string)
#   define DEBUG_fprintf(fp, fmt, var)
#   define DEBUG_okay(fp)
#   define DEBUG_memory(fp)
#   define DEBUG_BSprintbspc(x)
#   define DEBUG_send(objid) 
# endif

/* OM message codes */
# include "OMerrordef.h"

/* IF_NULL_OBJID IF_EQ_OBJID */
# include "OMmacros.h"

/* BSrc, BSOKAY, BS message codes */
# include "bserr.h"

/* EMSerror for EMSmsgReport; EMSokay, OR ... */
# include "EMSlogic.h"

/* EMSmsgReport */
# include "EMScmacros.h"

/* EMS_I_Fail could be returned from message EMSgencompsf.EMmake_comp */
# include "EMSmsgdef.h"

/* EMS_S_ClearStatusField */
# include "EMS_S.h"

/* EMS_E_CompositeFailed ... */
# include "EMS_E.h"

/* EMLS_NATURAL */
# include "EMSprop.h"

/* EMS_OPT_CONNECTABLE */
# include "EMSopt.h"

/* struct GRobj_env */
/* # include "grgs.h"
    GRobj_env is currently declared in growner.h which I am sure
    is included by the GRowner class, of which EMSgencompsf is a
    descendent.
*/

#   define testAndSetErr(msgNum)                        \
    if (NOT (okay = EMSokay (*rc) AND EMSokay (omrc)))  \
    {                                                   \
        if (EMSokay (omrc)) omrc = OM_E_ABORT;          \
        *rc = (msgNum);                                 \
    }

#   define setErr(msgNum)   \
    {                       \
        okay = FALSE;       \
        omrc = OM_E_ABORT;  \
        *rc = (msgNum);     \
    }

# define AUTO_SIDES 4
# define AUTO_COMPS (AUTO_SIDES + 2)

from EMSloopset import EMget_props;
/* from EMSsurface inherit EMmk_nat_bdry; */
/* from EMSsurface inherit EMgetedges; */
from EMSedge import EMget_bcxyz_geom;
from EMSsubbs import EMruled_surface;
/* from EMSgencompsf inherit EMmake_comp; */
from EMSplane import EMplaneContainingTwoClosedCurves;

/* from GRowner inherit GRadd_components, BUT */
    from GRgrgrp import GRadd_components;

method EMmkWNatSidesTw2S (
    IGRlong *rc;
    GRobjid surf1, surf2;
    struct GRvg_construct *construct_list;
    GRobjid parts[0]
)
{
    EMSrc omrc;
    IGRboolean okay = TRUE;
    GRobjid surf[2];

    int ee; /* edge iterator */
    int ss; /* input surface iterator */
    int pp; /* composite surface component iterator */

    IGRint cscomponentNum;
    GRobjid cscomponentArray[AUTO_COMPS];
    GRobjid *cscomponent = cscomponentArray;
    IGRboolean cscomponentAllocated = FALSE;

    GRobjid *side = &cscomponentArray[1];

    struct GRid *edge[2];
    IGRint edgeNum[2];

    /* begin non-automatic initializations */

    *rc = EMS_S_ClearStatusField;
    *construct_list->msg = EMS_E_UnusedCodeVariable;

    surf[0] = surf1;
    surf[1] = surf2;

    for (ss = 0; ss < 2; ss++)
    {
        edge[ss] = NULL;
        edgeNum[ss] = 0;
    }

    /* end non-automatic initializations */

    /* get edges of each surface: */

    for (ss = 0; ss < 2 AND okay ; ss++)
    {
        OMuword surfClassid;

        omrc = om$get_classid (
            objid = surf[ss],
            p_classid = &surfClassid
        );

        if (EMSokay (omrc))
        {
            extern OMuword OPP_EMSsubbs_class_id;

            omrc = om$is_ancestry_valid (
                subclassid = surfClassid,
                superclassid = OPP_EMSsubbs_class_id
            );
        }

        /* if error getting or testing classid */
        if (EMSerror (omrc)) setErr (EMS_E_OperationFailed);

        if (omrc IS OM_S_SUCCESS) /* class is subclass of EMSsubbs */
        {
            OM_S_CHANSELECT EMSsubbs_to_loopset_name;
            IGRushort properties;

            EMSsubbs_to_loopset_name.type = OM_e_name;
            EMSsubbs_to_loopset_name.u_sel.name = "EMSsubbs.to_loopset";

            omrc = om$send (
                msg = message EMSloopset.EMget_props (
                    rc,
                    &properties
                ),
                senderid = surf[ss],
                p_chanselect = &EMSsubbs_to_loopset_name
            );

            testAndSetErr (EMS_E_GetLoopsetProps);

            if (omrc IS OM_I_CHAN_EMPTY)
            {
                omrc = om$send (
                    msg = message EMSsurface.EMmk_nat_bdry (
                        rc,
                        &construct_list->env_info->md_env,
                        NULL /* edge_ids */
                    ),
                    targetid = surf[ss]
                );

                testAndSetErr (EMS_E_MkNaturalBoundary);
            }
/*
            We do not currently care what kind of loopset there
            is, so this condition is deleted via comment.

            else if (okay AND NOT (properties & EMLS_NATURAL))
            {
*/
                /* loopset is there, but it is not a natural loopset */
/*
                setErr (EMS_E_NoNaturalLoopset);

                DEBUG_EMSmsgReport (*rc, "after natural test");
            }
*/
        } /* end class is subclass of EMSsubbs */

        if (okay) /* natural loopset stuff */
        {
            IGRint zero = 0; /* buffer pointer is NULL */

            /* edgeNum[ss] is already 0; EMgetedges expects this */

            /*
                EMS_OPT_CONNECTABLE includes the restrictions
                of EMS_OPT_NONDEG_NONSEAM and ought to be the
                same in this case since we are working with a
                natural loopset.
            */

            DEBUG_fprintf(stderr, "before:  edge[%d]", ss);
            DEBUG_fprintf(stderr, " is %u; ", edge[ss]);
            DEBUG_fprintf(stderr, "zero is %d; ", zero);
            DEBUG_fprintf(stderr, "edgeNum[%d]", ss);
            DEBUG_fprintf(stderr, " is %d\n", edgeNum[ss]);

            DEBUG_memory (fp = stderr);

            omrc = om$send (
                msg = message EMSsurface.EMgetedges (
                    rc,
                    EMS_OPT_CONNECTABLE,
                    &edge[ss],      /* edges (buf) */
                    &zero,          /* buf_size */
                    &edgeNum[ss],   /* num_edges */
                    NULL,           /* surf_list */
                    NULL,           /* numed_list */
                    NULL,           /* list_size */
                    NULL            /* num_in_list */
                ),
                targetid = surf[ss]
            );

            DEBUG_memory (fp = stderr);

            DEBUG_fprintf(stderr, "after:  edge[%d]", ss);
            DEBUG_fprintf(stderr, " is %u; ", edge[ss]);
            DEBUG_fprintf(stderr, "zero is %d; ", zero);
            DEBUG_fprintf(stderr, "edgeNum[%d]", ss);
            DEBUG_fprintf(stderr, " is %d\n", edgeNum[ss]);

            testAndSetErr (EMS_E_NoConnectableEdges);

            DEBUG_memory (fp = stderr);

            if (okay AND edgeNum[ss] < 1)
            {
                setErr (EMS_E_NoConnectableEdges);
            }

            DEBUG_EMSmsgReport (*rc, "after edgesNum test");
            DEBUG_memory (fp = stderr);
        } /* end if (okay) natural loopset stuff */
    } /* end of get edges of each surface */

    DEBUG_memory (fp = stderr);

#   if DEBUG
    for (ss = 0; ss < 2; ss++)
    {
        DEBUG_fprintf(stderr, "in transit:  edge[%d]", ss);
        DEBUG_fprintf(stderr, " is %u; ", edge[ss]);
        DEBUG_fprintf(stderr, "edgeNum[%d]", ss);
        DEBUG_fprintf(stderr, " is %d\n", edgeNum[ss]);
    }
#   endif

    DEBUG_memory (fp = stderr);

    /* test number of edges; possibly allocate memory */

    if (okay)
    {
        if (edgeNum[0] ISNT edgeNum[1])
        {
            setErr (EMS_E_ConnEdgesNotMatch);
        }
        else
        {
            if (edgeNum[0] > AUTO_SIDES) /* must allocate */
            {
                DEBUG_memory (fp = stderr);
                DEBUG_fprintf (stderr, "allocation size is %u\n",
                    (unsigned)((2 + edgeNum[0]) * sizeof (GRobjid)));
                DEBUG_fprintf (stderr, "edgeNum[0] is %d\n", edgeNum[0]);
                DEBUG_memory (fp = stderr);

                cscomponent = (GRobjid *)om$malloc (
                    size = (unsigned)((2 + edgeNum[0]) * sizeof (GRobjid))
                );

                if (cscomponent)
                {
                    cscomponentAllocated = TRUE;
                    side = &cscomponent[1];
                }
                else
                {
                    setErr (EMS_E_InsufficientDynamicMemory);
                }
            }
        }
    } /* end of test number of edges; possibly allocate memory */

    DEBUG_memory (fp = stderr);

    /* initialize cscomponents -- intentional block */
    {
        if (okay)
        {
            cscomponentNum = edgeNum[0] + 2;
        }
        else
        {
            cscomponentNum = 2;
        }
        
        pp = cscomponentNum - 1;

        cscomponent[pp] = surf[1];
        while (--pp)
        {
            cscomponent[pp] = my_id;
        }
        cscomponent[0] = surf[0];
    }
    /* end of initialize cscomponents */

    /* make side for each pair of edges: */

    ee = edgeNum[0];
    while (ee-- /* > 0 */ AND okay)
    {
        struct IGRbsp_curve curve[2];
        struct GRid surfGRid[2];
        int bothClosed = FALSE, coplanar = FALSE;
        IGRvector unormal;

        /* initialize curve and surfGRid structures */
        for (ss = 0; ss < 2; ss++)
        {
            curve[ss].poles = NULL;
            curve[ss].weights = NULL;
            curve[ss].knots = NULL;
            curve[ss].bdrys = NULL; /* ought not be necessary */

            surfGRid[ss].objid = surf[ss];
            surfGRid[ss].osnum = OM_Gw_current_OS;
        }

        /* get edge equivalent in xyz space: */
        for (ss = 0; ss < 2 AND okay; ss++)
        {
            omrc = om$send (
                msg = message EMSedge.EMget_bcxyz_geom (
                    rc,
                    &construct_list->env_info->md_env,
                    NULL /* 20 Jun 1988 &surfGRid[ss] */,
                    NULL,
                    0,
                    OM_K_MAXINT,
                    FALSE,  /* do not reverse */
                    NULL,
                    &curve[ss]
                ),
                targetos = edge[ss][ee].osnum,
                targetid = edge[ss][ee].objid
            );

            testAndSetErr (EMS_E_EdGetXyzGeom);
        } /* end of get edge equivalent in xyz space */

        DEBUG_fprintf (stderr, "pair ee is %d\n", ee);
        DEBUG_okay (stderr);

        /* Since connectable edges are not degenerate, the
            degeneracy check ought be unnecessary, now. */
/*
        for (ss = 0; ss < 2 AND okay; ss++)
        {
            IGRboolean degenerate[2];
            BSrc bsrc;

*/          /* test for degenerate curve */
/*          BStstcvdegn (&curve[ss], &degenerate[ss], &bsrc);
            if (BSERROR (bsrc))
            {
                setErr (EMS_E_BsMathErIsDgnC);
            }

            if (degenerate[0] OR degenerate[1])
            {
                side[ee] = NULL_OBJID;
            }
        }
*/

        /* test for bothClosed */
        if (okay AND IF_EQ_OBJID (my_id, side[ee]))
        {
            ss = 1;

            do
            {
                BSrc clbsrc;

                BScvtstclsd (&curve[ss], &clbsrc);

                if (BSERROR (clbsrc))
                {
                    setErr (EMS_E_BsMathErIsClsdC);
                }
            } while (ss-- AND okay);

            if (okay)
            {
                bothClosed =
                    curve[0].phy_closed AND curve[1].phy_closed;

                if (curve[0].phy_closed ISNT curve[1].phy_closed)
                {
                    setErr (EMS_E_Exactly1OfEd2Closed);
                }
            }
        }
        /* end of test for bothClosed */

        DEBUG_fprintf (stderr, "bothClosed is %d\n", bothClosed);
        DEBUG_okay (stderr);

        /* test for coplanar */
        if (okay AND IF_EQ_OBJID (my_id, side[ee]))
        {
            BSrc cpbsrc;

            coplanar = BScvcoplan (
                &cpbsrc,
                &curve[0],
                &curve[1],
                unormal
            );

            /* do not check cpbsrc! probably okay */
        }
        /* end of test for coplanar */

        DEBUG_fprintf (stderr, "coplanar is   %d\n", coplanar);
        DEBUG_okay (stderr);

        /* if bothClosed and coplanar, make planar face */
        if (okay AND bothClosed AND coplanar AND
            IF_EQ_OBJID (my_id, side[ee]))
        {
            extern OMuword OPP_EMSplane_class_id;
            struct IGRbsp_curve *cvPtrArray[2];

            cvPtrArray[0] = &curve[0];
            cvPtrArray[1] = &curve[1];

            omrc = om$construct (
                classid = OPP_EMSplane_class_id,
                p_objid = &side[ee],
                msg = message EMSplane.EMplaneContainingTwoClosedCurves (
                    rc,
                    construct_list,
                    cvPtrArray
                )
            );

            testAndSetErr (EMS_E_EMSplaneConstruct);

            if (NOT okay) side[ee] = NULL_OBJID;
        }
        /* end of if bothClosed and coplanar, make planar face */

        DEBUG_okay (stderr);

        /* if not yet tried, make ruled surface */
        if (okay AND IF_EQ_OBJID (side[ee], my_id))
        {
            extern OMuword OPP_EMSgenbs_class_id;
            IGRpoint curveEndPoints[2];
            int cv = 1;

            do
            {
                int field = 2;

                do
                {
                    curveEndPoints[cv][field] =
                        curve[cv].poles[field];

                    /* poles of rational curves are weighted, so
                        weighting is not necessary */
                } while (field--);
            } while (cv--);

            DEBUG_fprintf (stderr, "side ee %d\n", ee);

            omrc = om$construct (
                classid = OPP_EMSgenbs_class_id,
                p_objid = &side[ee],
                msg = message EMSsubbs.EMruled_surface (
                    &curve[0], NULL,
                    &curve[1], NULL,
                    0, NULL, NULL,
                    curveEndPoints,
                    TRUE, /* orientation flag */
                    FALSE, FALSE, /* not reversed -- keep direction */
                    FALSE, FALSE, /* not used */
                    construct_list,
                    rc
                )
            );

            DEBUG_okay (stderr);
            DEBUG_send (objid = side[ee]);

            testAndSetErr (EMS_E_MkRuledS);

            if (okay) /* put natural loopset on it */
            {
                omrc = om$send (
                    msg = message EMSsurface.EMmk_nat_bdry (
                        rc,
                        &construct_list->env_info->md_env,
                        NULL
                    ),
                    targetid = side[ee]
                );

                testAndSetErr (EMS_E_MkNaturalBoundary);

                if (NOT okay) /* oops! delete that surface */
                {
                    EMSrc delemsrc, delomrc;

                    delomrc = om$send (
                        msg = message GRgraphics.GRdelete (
                            (IGRlong *)(&delemsrc),
                            construct_list->env_info
                        ),
                        targetid = side[ee]
                    );

                    EMSmsgReport (delemsrc, "EMgcsMkTw2sf dside", DEBUG);
                    EMSmsgReport (delomrc, "EMgcsMkTw2sf dsideom", DEBUG);

                    side[ee] = NULL_OBJID;
                } /* end oops! delete that surface */
            } /* end if okay, put natural loopset on it */
        } /* end of if not yet tried, make ruled surface */

        DEBUG_okay (stderr);

        /* free memory of curves */
        for (ss = 0; ss < 2; ss++)
        {
            if (curve[ss].poles)
                om$dealloc (ptr = curve[ss].poles);
            if (curve[ss].weights)
                om$dealloc (ptr = curve[ss].weights);
            if (curve[ss].knots)
                om$dealloc (ptr = curve[ss].knots);

            if (curve[ss].bdrys) /* ought not be necessary */
                om$dealloc (ptr = curve[ss].bdrys);
        }
    } /* end of make side for each pair of edges */

    DEBUG_fprintf (stderr, "cscomponentNum is %d\n", cscomponentNum);
    DEBUG_okay (stderr);

#   if DEBUG
    if (okay) for (pp = 0; pp < cscomponentNum; pp++)
    {
        DEBUG_fprintf (stderr, "cscomponent[%d]", pp);
        DEBUG_fprintf (stderr, " is %u\n", cscomponent[pp]);
    }
#   endif

    /* pack cscomponents, set cscomponentNum -- intentional block */
    {
        int nextToSpot = 1, localMax;

        localMax = cscomponentNum;

        for (pp = 1; pp < localMax; pp++)
        {
            OM_S_OBJID oid;

            oid = cscomponent[pp];

            if (IF_NULL_OBJID (oid) OR IF_EQ_OBJID (oid, my_id))
            {
                /* oid set to NULL_OBJID or left as my_id */

                cscomponentNum--;
            }
            else
            {
                if (pp ISNT nextToSpot)
                {
                    cscomponent[nextToSpot] = cscomponent[pp];
                }
                nextToSpot++;
            }
        }
    }
    /* end of pack cscomponents */

    DEBUG_fprintf (stderr, "cscomponentNum is %d\n", cscomponentNum);
    DEBUG_okay (stderr);

#   if DEBUG
    if (okay) for (pp = 0; pp < cscomponentNum; pp++)
    {
        DEBUG_fprintf (stderr, "cscomponent[%d]", pp);
        DEBUG_fprintf (stderr, " is %u\n", cscomponent[pp]);
    }
#   endif

    /* make composite */
    if (okay)
    {

        DEBUG_fprintf (stderr, "before EMmake_comp my_id is %d\n", my_id);

#       if BADMAKECOMP
            omrc = OM_E_ABORT;
#       else
            omrc = om$send (
                msg = message EMSgencompsf.EMmake_comp (
                    rc,
                    cscomponentNum,
                    cscomponent,
                    construct_list->env_info
                ),
                targetid = my_id
            );
#       endif

        DEBUG_fprintf (stderr, "after EMmake_comp my_id is %d\n", my_id);

        if (EMSerror (omrc) OR EMSerror (*rc) OR *rc IS EMS_I_Fail)
        {
            setErr (EMS_E_CompositeFailed);
        }

        DEBUG_okay (stderr);
    }
    /* end of make composite */

    DEBUG_fprintf (stderr, "after make composite\n", NULL);
    DEBUG_okay (stderr);

    /* begin return sequence */

    /* the next eight lines are to catch oversights: */

    okay = okay AND EMSokay (*rc) AND EMSokay (omrc);

    if (okay)
    {
        *rc = EMS_S_ClearStatusField;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        if (EMSokay (*rc)) *rc = EMS_E_OperationFailed;
        if (EMSokay (omrc)) omrc = OM_E_ABORT;
    }

    /* Upon return we need to set parts */

    if (parts)
    {
        if (okay OR cscomponentNum <= 2)
        {
            /* everything was okay, or there problems but no
                sides were created.
                actually, cscomponentNum ought never be < 2!
            */

            parts[0] = NULL_OBJID;
        }
        else /* there were problems, and sides have been created */
        {
            EMSrc constructOMrc;
            int addedAtLeastOne = FALSE;
            extern OMuword OPP_GRgrgrp_class_id;
            OM_S_OBJID groupId;

            construct_list->geometry = NULL;

            constructOMrc = om$construct (
                classid = OPP_GRgrgrp_class_id,
                msg = message GRvg.GRconstruct (construct_list),
                p_objid = &groupId
            );

            if (EMSokay (constructOMrc))
            {
                IGRint one = 1;
                struct GRobj_env obj_env;

                obj_env.mod_env = *construct_list->env_info;
                obj_env.obj_id.osnum = OM_Gw_current_OS;

                pp = cscomponentNum - 1;
                while (--pp) /* from cscomponentNum - 2 down to 1 */
                {
                    EMSrc addOMrc; IGRlong addRc;

                    obj_env.obj_id.objid = cscomponent[pp];

                    addOMrc = om$send (
                        msg = message GRgrgrp.GRadd_components (
                            &addRc,
                            construct_list->env_info,
                            &one,
                            &obj_env,
                            NULL,   /* so OM_K_MAXINT is used */
                            NULL    /* so OM_K_MAXINT is used */
                        ),
                        targetid = groupId
                    );

                    if (EMSokay (addOMrc) AND EMSokay (addRc))
                    {
                        addedAtLeastOne = TRUE;
                    }
                    else
                    {
                        /* delete side */

                        (void)om$send (
                            msg = message Root.delete (NULL),
                            targetid = cscomponent[pp]
                        );
                    }
                } /* iterate from cscomponentNum - 2 down through 1 */
            } /* end if construct group okay */

            if (addedAtLeastOne)
            {
                parts[0] = groupId;
            }
            else
            {
                parts[0] = NULL_OBJID;

                if (EMSokay (constructOMrc))
                {
                    (void)om$send (
                        msg = message Root.delete (NULL),
                        targetid = groupId
                    );
                }
            }
        }
    }

    /* free allocated memory */

    for (ss = 0; ss < 2; ss++)
    {
        if (edge[ss]) om$dealloc (ptr = edge[ss]);
    }
    if (cscomponentAllocated) om$dealloc (ptr = cscomponent);

    DEBUG_fprintf (stderr, "EMgcsMkTw2sf my_id %d\n", my_id);

    return omrc;
}

end implementation EMSgencompsf;
