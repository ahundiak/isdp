/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

06/04/91    DLB Support current_creator.
16 Jan 1991 pp  Added support for CGM translator.
10 Oct 1989 pp  Fixed a bug cropping from an assumption being made that
                tabulated cylinders will always be closed
10 Apr 1989 jBk Added workaround to ignore rule arcs which fail
                to convert in a pattern which is consistent
                between groups of rule arcs.
04 Apr 1989 jBk Enhanced conditionally compiled debugging code.
15 Mar 1989 jBk Instead of getting the module environment a la
                the source I have seen for the COcvigdsige
                implementation of cvt_type1819 (cvt_type1214), I
                now depend upon the module environment in
                me->current_env.
13 Mar 1989 jBk Added automatic variable "saved_elt_sizes" to sum
                up the size of the header and component parts of
                this element and put it into the instance buffer
                for later reference.
08 Feb 1989 jBk Made minor performance tweak.
18 Jan 1989 jBk Declared GUputname and GUgetname as external.
25 Jul 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
*/

# include "EMS.h"

# ifndef DEBUG
# define DEBUG 0
# endif

# if DEBUG
#   ifndef SHOWCALLS
#   define SHOWCALLS 1
#   endif
# endif

# ifndef WHICHGROUP
# define WHICHGROUP 0
# endif

# ifndef TRYINGSOLID
# define TRYINGSOLID 0
# endif

# ifndef SHOWCALLS
# define SHOWCALLS 0
# endif

# if DEBUG || WHICHGROUP || TRYINGSOLID || SHOWCALLS
#   include <stdio.h>
    extern int EFmsgReport ();
# endif

/* GRIS_PLANAR GRIS_NEW GRIS_MODIFIED GRIS_LOCATABLE GRIS_DISPLAYABLE */
# include "godef.h"

/* GU_SOLID */
# include "transdef.h"

/* AND IS EMSokay EMSerror */
# include "EMSlogic.h"

/* EMS_W_Fail */
# include "EMSmsgdef.h"

/* surface/solid class definitions */
# include "EMSigdsdef.h"

/* IGDS_sv1819 */
# include "EMSigds.h"

/* symbology derivation macros */
# include "EMSigdsmac.h"

/* IF_NULL_OBJID */
# include "OMmacros.h"

/* compile switch settings */
# include "exsysdep.h"

from GRvg import GRconstruct;
from GRconnector import GRflexconn;
from GRgraphics import GRdelete;
from EMSsfsolid import EMcap_thyself;

method cvt_type1819 (IGRlong *msg; struct GRid *object_info)
{
#   if SHOWCALLS
    static countFailures = 0;
    static numCalls = 0;
#   endif
    EMSrc omrc;
    struct GRvg_construct list;
    struct IGDS_sv1819 igdssv;
    IGRint igdstype; /* type of igds element */
    IGRshort igdscount; /* count of elements according to igds */
    IGRint igdssvtype;  /* which kind of type 18 or 19 */
    IGRint igdscpb;     /* number of Curves Per Boundary */
    IGRboolean has_name;
    IGRchar name[257];
    IGRint numSections;
    struct GRid firstBoundaryGroup;
    struct GRid boundaryGroup, ruleArcGroup, connectGroup;
    struct GRid otherGroup;
    struct IGRdisplay display;
    IGRboolean okayToName = FALSE;
    IGRboolean moveToErrorLayer = FALSE;
    IGRlong saved_elt_sizes;

#   if SHOWCALLS
    (void)fprintf (stderr, "%d ECcvty1819.I into\n", ++numCalls);
#   endif

#ifdef BIG_ENDIAN
    GRswap_type1819_ele(me->cvt_bufs.ele_buf);
#endif
    saved_elt_sizes = me->cvt_bufs.ele_size;

    igdssv = *((struct IGDS_sv1819 *) me->cvt_bufs.ele_buf);
    igdstype = me->cvt_bufs.ele_type;
    igdscount = igdssv.num_elements;
    igdssvtype = igdssv.svType;
    igdscpb = igdssv.curvesPerBoundary + 1;


#   if SHOWCALLS
    (void)fprintf (stderr, "igdssvtype is %d\n", igdssvtype);
    (void)fprintf (stderr, "igdscount is %d\n", igdscount);
    (void)fprintf (stderr, "igdstype is %d\n", igdstype);
    (void)fprintf (stderr, "igdscpb is %d\n", igdscpb);
#   endif

    /* intentional block to set up properties word */
    {
        IGRushort  properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

        if (igdssv.header.properties & 0x2000)
        {
            properties |= GRIS_PLANAR;
        }
        if (igdssv.header.properties & 0x0200)
        {
            properties |= GRIS_NEW;
        }
        if (igdssv.header.properties & 0x0400)
        {
            properties |= GRIS_MODIFIED;
        }

        list.properties = properties;
    }

    list.msg = msg;
    list.env_info = &me->current_env;
    list.newflag = FALSE;
    list.level = igdssv.header.level & 0x3f;
    list.geometry = NULL;
    list.display = &display;
    list.class_attr = NULL;
    list.name = NULL;

/* Begin support for CGM */
    {
        IGRint has_link;
        extern IGRint GUattr_link ();

        /*
            Check the user data linkage for an element name.
        */

        has_link = GUattr_link(msg, &igdssv.header,name,
                   &igdssv.header.symbology,NULL,NULL);
        has_name = (has_link & HAS_NAME_TYPE);

        display.color =
           IGDS_SYMBOLOGY_TO_IEMS_COLOR (igdssv.header.symbology);
        display.weight =
           IGDS_SYMBOLOGY_TO_IEMS_WEIGHT (igdssv.header.symbology);
        display.style =
           IGDS_SYMBOLOGY_TO_IEMS_STYLE (igdssv.header.symbology);
    }
/* end support */


    /*
        I lifted the following three lines from I/Draft's
        GUconstruct function, and modified them to fit here and
        to use mnemonic macros.
    */

    display.color =
        IGDS_SYMBOLOGY_TO_IEMS_COLOR (igdssv.header.symbology);
    display.weight =
        IGDS_SYMBOLOGY_TO_IEMS_WEIGHT (igdssv.header.symbology);
    display.style =
        IGDS_SYMBOLOGY_TO_IEMS_STYLE (igdssv.header.symbology);

    if (EMSokay (*msg)) /* if checked name okay */
    {
        extern OMuword OPP_GRgrgrp_class_id;
        int otherGroupNotUsed = TRUE;
        struct GRid componentElement;
        /*
            I ought to have declared componentElement in the
            while loop, but because GUconstruct expects its osnum
            to be set properly, I have moved the declaration out
            here to avoid repeated setting of its osnum.
        */
        int lastcvclass;
        int cvclass = -1; /* impossible cvclass */
        int ii = 0;

        int rAix;   /* index of success flag in me->ints */
        int rAgroup = 0;    /* rule arc group number */
        int rApergroup = 0; /* rule arcs per group; set in group #1 */
        int rAsuccessSoFar = TRUE;  /* rule arcs converted okay so far */
        int okayToScratchRuleArcs = TRUE;

        firstBoundaryGroup.osnum = me->current_env.md_id.osnum;
        boundaryGroup.osnum = firstBoundaryGroup.osnum;
        ruleArcGroup.osnum = firstBoundaryGroup.osnum;
        connectGroup.osnum = firstBoundaryGroup.osnum;
        object_info->osnum = firstBoundaryGroup.osnum;
        componentElement.osnum = firstBoundaryGroup.osnum;
        otherGroup.osnum = firstBoundaryGroup.osnum;

        omrc = om$construct (
            msg = message GRvg.GRconstruct (&list),
            classid = OPP_GRgrgrp_class_id,
            osnum = object_info->osnum,
            p_objid = &object_info->objid
        );

        if (EMSokay (omrc) AND EMSokay (*msg))
        {
            okayToName = TRUE; /* we created something to name */

            omrc = om$construct (
                msg = message GRvg.GRconstruct (&list),
                classid = OPP_GRgrgrp_class_id,
                osnum = firstBoundaryGroup.osnum,
                p_objid = &firstBoundaryGroup.objid
            );
        }

        if (EMSokay (omrc) AND EMSokay (*msg))
        {
            omrc = om$construct (
                msg = message GRvg.GRconstruct (&list),
                classid = OPP_GRgrgrp_class_id,
                osnum = boundaryGroup.osnum,
                p_objid = &boundaryGroup.objid
            );
        }

        if (EMSokay (omrc) AND EMSokay (*msg))
        {
            omrc = om$construct (
                msg = message GRvg.GRconstruct (&list),
                classid = OPP_GRgrgrp_class_id,
                osnum = ruleArcGroup.osnum,
                p_objid = &ruleArcGroup.objid
            );
        }

        if (EMSokay (omrc) AND EMSokay (*msg))
        {
            omrc = om$construct (
                msg = message GRvg.GRconstruct (&list),
                classid = OPP_GRgrgrp_class_id,
                osnum = otherGroup.osnum,
                p_objid = &otherGroup.objid
            );
        }

        /* ii initialized at declaration */
        for (;ii < igdscount AND EMSokay (omrc) AND EMSokay (*msg); ii++)
        {
            IGRlong trueflag = TRUE;
            IGRlong maxint = OM_K_MAXINT;
            int componentConversionFailed = FALSE;

            omrc = om$send (
                msg = message ECigdsiems.cvt_next_ele (
                    msg,
                    &componentElement
                ),
                targetid = my_id
            );

            saved_elt_sizes += me->cvt_bufs.ele_size;

            lastcvclass = cvclass;

            cvclass = 0xf &
                ((struct GUcommon_header_info *) me->cvt_bufs.ele_buf)->
                    properties;

#           if WHICHGROUP

            (void)fprintf (stderr, "cne send ii is %d\n", ii);
            (void)EFmsgReport (NULL, omrc, "cne send omrc");
            (void)EFmsgReport (NULL, *msg, "cne send *msg");

#           endif

            if (EMSokay (omrc) AND EMSokay (*msg))
            {
                omrc = om$send (
                msg = message GRconnector.GRflexconn (
                        msg,
                        &trueflag,
                        object_info,
                        &maxint,
                        &maxint
                    ),
                    targetid = componentElement.objid,
                    targetos = componentElement.osnum
                );

                if (omrc IS OM_E_NOSUCHOBJ)
                {
                    /* likely that the posting of the previously
                        converted component changed its class,
                        invalidating its object id
                    */

                    componentConversionFailed = TRUE;
                }
            }
            else
            {
                componentConversionFailed = TRUE;
            }

            if (okayToScratchRuleArcs AND (cvclass IS 4 OR cvclass IS 6))
            {
                /* handle missing rule arcs, if any */

                int dim;

                dim = om$dimension_of (varray = me->ints);

                if (lastcvclass ISNT 4 AND lastcvclass ISNT 6)
                {
                    /* this must be start of new rule arc group */

                    rAix = 0;
                    rAgroup++;
                }
                else
                {
                    /* in midst of rule arc group */

                    rAix++;
                }

                if (rAgroup IS 1)
                {
                    rApergroup++;

                    if (componentConversionFailed)
                    {
                        EMSrc rAomrc1 = OM_S_SUCCESS;
                        int jj;

                        if (dim < rApergroup)
                        {
                            rAomrc1 = om$vla_set_dimension (
                                varray = me->ints,
                                size = rApergroup
                            );
                        }

                        jj = rAix;

                        if (rAsuccessSoFar)
                        {
                            rAsuccessSoFar = FALSE;

                            /* need to initialize me->ints */

                            jj = 0;
                        }

                        if (EMSokay (rAomrc1))
                        {
                            /*
                                previous attempts were
                                successful; flag them as such
                            */

                            while (jj < rAix)
                            {
                                me->ints[jj++] = TRUE;
                            }

                            /*
                                flag this attempt a failure
                            */

                            me->ints[jj] = FALSE;
                        }
                        else
                        {
                            /* memory problem */

                            okayToScratchRuleArcs = FALSE;
                        }
                    }
                    else if (NOT rAsuccessSoFar)
                    {
                        /*
                            there have already been failures so
                            we need to flag this success
                        */

                        EMSrc rAomrc2 = OM_S_SUCCESS;

                        if (dim < rApergroup)
                        {
                            rAomrc2 = om$vla_set_dimension (
                                varray = me->ints,
                                size = rApergroup
                            );
                        }

                        if (EMSokay (rAomrc2))
                        {
                            me->ints[rAix] = TRUE;
                        }
                        else
                        {
                            /* memory problem */

                            okayToScratchRuleArcs = FALSE;
                        }
                    }

                } /* rAgroup IS 1 */
                else
                { /* rAgroup ISNT 1 */

                    if (NOT rAsuccessSoFar)
                    {
                        if (componentConversionFailed)
                        {
                            okayToScratchRuleArcs = NOT me->ints[rAix];

                            /* previous conversions at this index
                                into groups ought have been false
                            */
                        }
                        else
                        {
                            okayToScratchRuleArcs = me->ints[rAix];

                            /* previous conversions at this index
                                into groups ought have been true
                            */
                        }
                    }
                    else if (componentConversionFailed)
                    {
                        /* no failures in initial rule arc group
                            so not okay to scratch rule arcs
                        */

                        okayToScratchRuleArcs = FALSE;
                    }

                } /* else rAgroup ISNT 1 */

            } /* handle missing rule arcs, if any */

#           if WHICHGROUP

            if (EMSerror (omrc) OR EMSerror (*msg))
            {
                (void)fprintf (stderr,
                    "connect group is WG %d\n", cvclass);
            }

            (void)EFmsgReport (NULL, omrc, "*ob conn omrc");
            (void)EFmsgReport (NULL, *msg, "*ob conn *msg");

#           endif

            if (EMSokay (omrc) AND EMSokay (*msg))
            {
                /* connected to universal group */

                switch (cvclass) /* class */
                {
                case 0:
                    if (ii < igdscpb)
                    {
                        connectGroup.objid = firstBoundaryGroup.objid;
                    }
                    else
                    {
                        connectGroup.objid = boundaryGroup.objid;
                    }

#                   if WHICHGROUP
                    (void)fprintf (stderr,
                        "connect group is %s %d\n",
                        (ii < igdscpb) ? "1b" : "bd",
                        cvclass);
#                   endif

                    break;

                case 4:
                case 6:
                    connectGroup.objid = ruleArcGroup.objid;

#                   if WHICHGROUP
                    (void)fprintf (stderr,
                        "connect group is rA %d\n",
                        cvclass);
#                   endif

                    break;

                default:
                    connectGroup.objid = otherGroup.objid;

                    otherGroupNotUsed = FALSE;

#                   if WHICHGROUP
                    (void)fprintf (stderr,
                        "connect group is oG %d\n",
                        cvclass);
#                   endif

                    /* break; not necessary */
                }

                if (NOT IF_NULL_OBJID (connectGroup.objid))
                {
                    omrc = om$send (
                    msg = message GRconnector.GRflexconn (
                            msg,
                            &trueflag,
                            &connectGroup,
                            &maxint,
                            &maxint
                        ),
                        targetid = componentElement.objid,
                        targetos = componentElement.osnum
                    );

#                   if WHICHGROUP
                    (void)EFmsgReport (NULL, omrc, "cng conn omrc");
                    (void)EFmsgReport (NULL, *msg, "cng conn *msg");
#                   endif
                }
#               if DEBUG
                else
                {
                    (void)fprintf (stderr, "cng NULL_OBJID\n");
                }
#               endif

            } /* fi connected to universal group */

            if (componentConversionFailed)
            {
                /* try to continue to group the components */

                if (NOT (
                    (cvclass IS 4 OR cvclass IS 6) AND
                    okayToScratchRuleArcs
                ))
                {
                    /* if not a scratchable rule arc,
                        then we'll have to move the result to the
                        error layer
                    */

                    moveToErrorLayer = TRUE;
                }

                omrc = OM_S_SUCCESS;
                *msg = MSSUCC;
            }

        } /* end for */

        if (NOT moveToErrorLayer AND NOT rAsuccessSoFar AND
            okayToScratchRuleArcs)
        {
            /*
                make certain at least one rule element in each
                group of rule elements converted okay
            */

            int *p_ints;

            ii = rApergroup;
            p_ints = me->ints;

            okayToScratchRuleArcs = FALSE;

            do
            {
                okayToScratchRuleArcs |= *p_ints++;
            } while (--ii);

            moveToErrorLayer = NOT okayToScratchRuleArcs;
        }

        if (moveToErrorLayer)
        {
            if (EMSokay (omrc)) omrc = OM_E_ABORT;
            if (EMSokay (*msg)) *msg = MSFAIL;
        }

        if (otherGroupNotUsed)
        {
            EMSrc delom, delrc;

            delom = om$send (
                msg = message GRgraphics.GRdelete (
                    (IGRlong *)&delrc,
                    &me->current_env
                ),
                targetid = otherGroup.objid,
                targetos = otherGroup.osnum
            );

            otherGroup.objid = NULL_OBJID;
        }
    }

    /* get the number of sections */

    if (EMSokay (omrc) AND EMSokay (*msg))
    {
        omrc = om$send (
            msg = message ECigdsiems.ECnumSections (
                (EMSrc *)msg,
                igdscpb,
                boundaryGroup,
                &numSections
            ),
            targetid = my_id
        );
    }

    /* construct appropriate kind of surface */

    if (EMSokay (omrc) AND EMSokay (*msg))
    {
        struct GRid surface;
        IGRboolean oughtToClose = FALSE;

        switch (igdssvtype)
        {
        case IGDS_GU_SURFACE_TABULATED_CYLINDER:

/*
 *          oughtToClose = TRUE;
 * Removed this as this is a necessity. pp (10/10/89)
 */

        case IGDS_GU_SURFACE_SURFACE_OF_PROJECTION:
        case IGDS_GU_SURFACE_RIGHT_CIRCULAR_CYLINDER:
            omrc = om$send (
                msg = message ECigdsiems.ECsurfaceOfProjection (
                    (EMSrc *)msg,
                    *object_info,
                    igdscpb,
                    oughtToClose,
                    ((igdstype == GU_SOLID) ? 1 : 0),
                    numSections,
                    firstBoundaryGroup,
                    boundaryGroup,
                    ruleArcGroup,
                    otherGroup,
                    &list,
                    &surface
                ),
                targetid = my_id
            );
            break;
        case IGDS_GU_SURFACE_RIGHT_CIRCULAR_CONE:
            omrc = om$send (
                msg = message ECigdsiems.EC1819rightCircularCone (
                    (EMSrc *)msg,
                    *object_info,
                    igdscpb,
                    numSections,
                    firstBoundaryGroup,
                    boundaryGroup,
                    ruleArcGroup,
                    otherGroup,
                    &list,
                    &surface
                ),
                targetid = my_id
            );
            break;
        case IGDS_GU_SURFACE_SURFACE_OF_REVOLUTION:
            omrc = om$send (
                msg = message ECigdsiems.ECsurfaceOfRevolution (
                    (EMSrc *)msg,
                    *object_info,
                    igdscpb,
                    ((igdstype == GU_SOLID) ? 1 : 0),
                    numSections,
                    firstBoundaryGroup,
                    boundaryGroup,
                    ruleArcGroup,
                    otherGroup,
                    &list,
                    &surface
                ),
                targetid = my_id
            );
            break;
        case IGDS_GU_SURFACE_CONVOLUTE:
        case IGDS_GU_SURFACE_WARPED_SURFACE:
            omrc = om$send (
                msg = message ECigdsiems.ECconvolutedOrWarpedSurface (
                    (EMSrc *)msg,
                    *object_info,
                    igdscpb,
                    numSections,
                    firstBoundaryGroup,
                    boundaryGroup,
                    ruleArcGroup,
                    otherGroup,
                    &list,
                    &surface
                ),
                targetid = my_id
            );
            break;
        case IGDS_GU_SURFACE_BOUNDED_PLANE:
        case IGDS_GU_SURFACE_UNBOUNDED_PLANE:
        case IGDS_GU_SURFACE_TABULATED_CONE:
            /* these are not implemented */
            /* leave groups as they are: */ surface = *object_info;
            /* cannot cap graphic group: */ igdstype = GU_SURFACE;
            break;
        default:
            omrc = OM_E_ABORT;
            /* break not necessary */
        } /* end switch (igdssvtype) */

        if (EMSokay (omrc) AND EMSokay (*msg))
        {
            *object_info = surface;
        }
        else
        {
            moveToErrorLayer = TRUE;

            if (*msg IS EMS_W_Fail)
            {
                /* move malformed surface(s) to error layer */
                *object_info = surface;
            }
            /*
                else leave universal group in object_info so it
                can be moved to the error layer
            */
        }
    } /* fi construct appropriate kind of surface */

    /* if solid then cap surface */

    if (igdstype IS GU_SOLID AND EMSokay (omrc) AND EMSokay (*msg))
    {
        extern OMuword OPP_EMSsfsolid_class_id;
        GRobjid solid;

#       if TRYINGSOLID
        (void)fprintf (stderr, "Trying to cap solid\n");
#       endif

        omrc = om$construct(classid = OPP_EMSsfsolid_class_id,
                            osnum = object_info->osnum,
                            p_objid = &solid);
        if (1 & omrc)
        {
          extern OM_S_OBJID current_creator;
          current_creator = solid;
          omrc = om$send(msg = message EMSsfsolid.EMcap_thyself(msg,
                               &list, &object_info->objid),
                         targetid = solid,
                         targetos = object_info->osnum);
          current_creator = NULL_OBJID;
        }

#       if TRYINGSOLID
        EFmsgReport (NULL, omrc, "capping omrc");
        EFmsgReport (NULL, *msg, "capping *msg");
#       endif

        if (EMSokay (omrc) AND EMSokay (*msg))
        {
            object_info->objid = solid;
        }
        else
        {
            /* move attempted capped surface to error layer */
            moveToErrorLayer = TRUE;
        }
    }

    /* if it is supposed to have a name, name the result */

    if (has_name AND okayToName)
    {
        EMSrc nameRc;
        extern IGRlong GUputname ();

        GUputname (&nameRc, name, object_info, &me->current_env);
    }

    if (moveToErrorLayer)
    {
        EMSrc moveRc;

        (void)om$send (
            msg = message ECigdsiems.ECmoveToErrorLayer (
                &moveRc,
                *object_info,
                me->current_env.md_id
            ),
            targetid = my_id
        );
    }

    /* polish returned message codes */

    if (EMSokay (omrc) AND EMSokay (*msg))
    {
        *msg = MSSUCC;
        omrc = OM_S_SUCCESS;
    }
    else
    {
        *msg = MSFAIL;
        omrc = OM_E_ABORT;
    }

#   if SHOWCALLS

    if (EMSerror (omrc) OR EMSerror (*msg))
    {
        (void)fprintf (stderr, "%d ECcvty1819.I failure is %d ",
            numCalls, ++countFailures);
    }

    (void)fprintf (stderr, "%d ECcvty1819.I exit \n", numCalls);

#   endif

    me->cvt_bufs.ele_size = saved_elt_sizes;

    return omrc;
}

end implementation ECigdsiems;
