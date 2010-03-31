/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
HISTORY

22 Jun 1989 jBk If not all elements of an orphan cell are closed
                and planar curves and if no errors have been
                encountered, do not move cell to error layer
                because no attempt to do so ought to have been
                made.  That is, let it be.
04 Apr 1989 jBk Enhanced conditionally compiled debugging code.
28 Mar 1989 jBk Oops!  I left out the check for curve mentioned
                in the previous historical note!  Corrected.
23 Mar 1989 jBk Re-established checking of elements of an orphan
                cell to make certain they are all closed, planar,
                curves.
                Originally I forgot to move to the error layer
                those cases of orphan cells which did not make it
                all the way to being planes.  I have corrected
                this oversight. 
18 Jan 1989 jBk Genesis.
*/

# include "EMS.h"

# ifndef DEBUG
# define DEBUG 0
# endif

# ifndef SHOWCLASS
# define SHOWCLASS 0
# endif

# ifndef SHOWCALLS
# define SHOWCALLS 0
# endif

# ifndef ERRORLAYER
# define ERRORLAYER 0
# endif

# if DEBUG || SHOWCLASS || SHOWCALLS || ERRORLAYER
#   ifdef COUNTCALLS
#   undef COUNTCALLS
#   endif
#   define COUNTCALLS 1
# endif

# ifndef COUNTCALLS
# define COUNTCALLS 0
# endif

# include <stdio.h> /* sscanf */

/* GRCURVE */
# include "godef.h"

/* for grio.h */
# include "griodef.h"

/* struct GRlc_info */
# include "grio.h"

/* NOT AND OR IS EMSokay EMSerror */
# include "EMSlogic.h"

/* EMS_E_Fail */
# include "EMSmsgdef.h"

/* EMS_E_InsufficientDynamicMemory */
# include "EMS_E.h"

/* for compile switch settings */
# include "exsysdep.h"

from GRowner import GRget_components;
from GRowner import GRget_number_components;
from GRvg import GRgetprops;
from GRvg import GRgeomprops;
from GRvg import GRgetsymb;
from GRgraphics import GRdelete;

method cvt_type2 (
    IGRlong *rc;
    struct GRid *objectInfo
)
{
    EMSrc omrc;
    static int nested = 0;
    int try = FALSE;
    int hasName = FALSE;
    int name[257];

    short  ndices;

#   if COUNTCALLS

    static int staticNumCalls = 0;
    int numCalls;

    numCalls = ++staticNumCalls;

#   endif

#   if SHOWCALLS

    (void)fprintf (stderr, "%d ECcvty2.I into\n", numCalls);

#   endif

#ifdef BIG_ENDIAN
   if ( me->IGDS_file_type == GU_2I )
	  ndices = 10;
   else
	    ndices = 18;
	  GRswap_type2_ele(me->cvt_bufs.ele_buf,ndices);
#endif
    if (!((IGRshort)(*me->cvt_bufs.ele_buf) & 0x0080))
    {
        struct IGDS_cell *igdscell;

        igdscell = (struct IGDS_cell *)me->cvt_bufs.ele_buf;

        /*
            if H-bit is set, this is an orphan cell;
            test H-bit and act accordingly:
        */

        if (igdscell->header.properties & 0x8000)
        {
            extern int GUrad50_to_ascii ();
            IGRlong numWords = 2;
            IGRshort *radix50name;
            IGRchar cellName[2][7];
            int matches;

            radix50name = (IGRshort *)&igdscell->cell_data;
            radix50name++;
            GUrad50_to_ascii (&numWords, radix50name, cellName[0]);

            matches = sscanf (cellName[0], "%s", cellName[1]);
            /* matches = sscanf (cellName[0], "%s", cellName[1]); */

            if (try = matches IS EOF) /* no name */
            {
                extern IGRboolean GUgetname ();
                extern IGRint GUattr_link ();
                IGRint has_link;
                IGRshort symb;
                /*
                    Check the user data linkage for an element name.
                */
                has_link = GUattr_link(rc, &igdscell->header,name,
                           &symb,NULL,NULL);
                hasName = (has_link & HAS_NAME_TYPE);
            } /* fi no name */

        } /* fi H-bit is set, this is an orphan cell */

    } /* fi (NOT nested) */

    nested++;

    omrc = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECigdsiems.cvt_type2 (
            rc,
            objectInfo
        ),
        targetid = my_id
    );

    nested--;

    if (try AND EMSokay (omrc) AND EMSokay (*rc))
    {
        /*
            try to convert to bounded plane

            According to Mike Lanier, I don't have to worry about
            the transformation matrix nor the origin of the
            unnamed orphan cell header since they are ignored by
            the the IGDS-based shading software.
        */

        IGRint count;
        OM_S_OBJID planeId;
        struct GRid *p_childGRid = NULL;
        struct GRid *tmp_p_childGRid;
        struct GRlc_info *p_childLCinfo = NULL;
        IGRshort properties;
        struct GRsymbology symbology;
        int allClosedAndPlanarCurves = TRUE;

        omrc = om$send (
            msg = message GRowner.GRget_number_components (
                rc,
                &count
            ),
            targetid = objectInfo->objid,
            targetos = objectInfo->osnum
        );

        if (EMSokay (omrc) AND EMSokay (*rc))
        { /* allocate memory for dynamic arrays */

            if (count)
            {
                p_childGRid = (struct GRid *)om$malloc (
                    size = (count * sizeof (struct GRid))
                );

                p_childLCinfo = (struct GRlc_info  *)om$malloc (
                    size = (count * sizeof (struct GRlc_info))
                );

                if (NOT (p_childGRid AND p_childLCinfo))
                {
                    *rc = EMS_E_InsufficientDynamicMemory;
                }
            }
            else
            {
                *rc = EMS_E_Fail;
            }

        } /* fi allocate memory for dynamic arrays */

        if (EMSokay (omrc) AND EMSokay (*rc))
        { /* get children */

            IGRint dummyCount;

            omrc = om$send (
                msg = message GRowner.GRget_components (
                    rc,
                    &me->current_env,
                    p_childGRid,
                    count,
                    &dummyCount,
                    0,
                    count - 1
                ),
                targetid = objectInfo->objid,
                targetos = objectInfo->osnum
            );

            if (EMSokay (omrc) AND EMSokay (*rc))
            { /* got children */

                if (dummyCount ISNT count) /* count mismatch */
                {
                    *rc = EMS_E_Fail;
                }
                else
                { /* get properties */

                    omrc = om$send (
                        msg = message GRvg.GRgetprops (
                            rc,
                            &properties
                        ),
                        targetid = p_childGRid[0].objid,
                        targetos = p_childGRid[0].osnum
                    );

                    /*
                        Turn off the rigid relationship
                        properties bit since the new item will
                        not be a child in a rigid relationship.
                    */

                    properties &= ~(GR_RIGID_RELATIONSHIP);

                } /* end else get properties */

            } /* fi got children */

        } /* fi get children */

        if (EMSokay (omrc) AND EMSokay (*rc))
        { /* get symbology */

            omrc = om$send (
                msg = message GRvg.GRgetsymb (
                    rc,
                    &symbology
                ),
                targetid = p_childGRid[0].objid,
                targetos = p_childGRid[0].osnum
            );

        } /* fi get symbology */

        /* intentional block */
        { /* define jj */

            int jj;

            for (
                jj = count, tmp_p_childGRid = p_childGRid;

                jj AND allClosedAndPlanarCurves AND
                EMSokay (omrc) AND EMSokay (*rc);

                jj--, tmp_p_childGRid++
            )
            { /* check planarity and closure of contents */

                struct GRprops geomprops;

                omrc = om$send (
                    msg = message GRvg.GRgeomprops (
                        rc,
                        &me->current_env.md_env.matrix_type,
                        me->current_env.md_env.matrix,
                        &geomprops
                    ),
                    targetid = tmp_p_childGRid->objid,
                    targetos = tmp_p_childGRid->osnum
                );

                allClosedAndPlanarCurves =
                    (geomprops.type IS GRCURVE) AND
                    (geomprops.closed OR geomprops.phy_closed) AND
                    geomprops.planar;

#               if SHOWCLASS
                {
                    EMSrc classRc;
                    char className[OM_K_MAXCLASS_LEN];

                    classRc = om$get_classname (
                        objid = tmp_p_childGRid->objid,
                        osnum = tmp_p_childGRid->osnum,
                        classname = className
                    );

                    if (EMSokay (classRc))
                    {
                        (void)fprintf (stderr,
                            "%d ECcvty2.I child %d %d %s %s %s %s\n",
                            numCalls,
                            tmp_p_childGRid->osnum,
                            tmp_p_childGRid->objid,
                            className,
                            geomprops.closed OR geomprops.phy_closed ?
                                "closed" : "open",
                            geomprops.planar ?
                                "planar" : "non-planar",
                            geomprops.type IS GRCURVE ?
                                "curve" : "non-curve"
                        );
                    }
                    else
                    {
                        extern int EFmsgReport ();

                        (void)fprintf (stderr, "%d ECcvty2.I class 0x%x ",
                            numCalls, classRc);
                        EFmsgReport(stderr, classRc, "classRc ECcvty2.I");
                    }

                }
#               endif

            } /* check planarity and closure of contents */

#           if SHOWCLASS
            if (allClosedAndPlanarCurves)
            {
                if (EMSerror (omrc) OR EMSerror (*rc))
                {
                    extern int EFmsgReport ();

                    EFmsgReport (stderr, omrc, "ECcvty2.I omrc");
                    EFmsgReport (stderr, *rc, "ECcvty2.I *rc");
                }
            }
            else for (
                /* leave jj and tmp_p_childGRid as they are */;

                jj AND EMSokay (omrc) AND EMSokay (*rc);

                jj--, tmp_p_childGRid++
            )
            { /* report planarity and closure of contents */

                struct GRprops geomprops;

                omrc = om$send (
                    msg = message GRvg.GRgeomprops (
                        rc,
                        &me->current_env.md_env.matrix_type,
                        me->current_env.md_env.matrix,
                        &geomprops
                    ),
                    targetid = tmp_p_childGRid->objid,
                    targetos = tmp_p_childGRid->osnum
                );

                {
                    EMSrc classRc;
                    char className[OM_K_MAXCLASS_LEN];

                    classRc = om$get_classname (
                        objid = tmp_p_childGRid->objid,
                        osnum = tmp_p_childGRid->osnum,
                        classname = className
                    );

                    if (EMSokay (classRc))
                    {
                        (void)fprintf (stderr,
                            "%d ECcvty2.I chilD %d %d %s %s %s %s\n",
                            numCalls,
                            tmp_p_childGRid->osnum,
                            tmp_p_childGRid->objid,
                            className,
                            geomprops.closed OR geomprops.phy_closed ?
                                "closed" : "open",
                            geomprops.planar ?
                                "planar" : "non-planar",
                            geomprops.type IS GRCURVE ?
                                "curve" : "non-curve"
                        );
                    }
                    else
                    {
                        extern int EFmsgReport ();

                        (void)fprintf (stderr, "%d ECcvty2.I clasS 0x%x ",
                            numCalls, classRc);
                        EFmsgReport(stderr, classRc, "clasSRc ECcvty2.I");
                    }

                }

            } /* report planarity and closure of contents */

#           endif

        } /* define jj */

        if (allClosedAndPlanarCurves AND EMSokay (omrc) AND EMSokay (*rc))
        { /* try to construct plane */

            int ii;
            struct GRvg_construct list;
            struct GRlc_info *p_lcInfo;
            struct GRid *p_GRid;
            extern IGRlong EFplace_nested_plane ();

            for (
                ii = 0, p_lcInfo = p_childLCinfo, p_GRid = p_childGRid;
                ii < count;
                ii++, p_lcInfo++, p_GRid++
            )
            {
                p_lcInfo->located_obj = *p_GRid;
                p_lcInfo->module_info = me->current_env;
                p_lcInfo->proj_pnt[0] = 0.0;
                p_lcInfo->proj_pnt[1] = 0.0;
                p_lcInfo->proj_pnt[2] = 0.0;
                p_lcInfo->geom_parms.u = 0.0;
                p_lcInfo->geom_parms.v = 0.0;
                p_lcInfo->geom_parms.polygon_inx = 3;
                p_lcInfo->geom_parms.leaf_id.osnum = 0;
                p_lcInfo->geom_parms.leaf_id.objid = NULL_OBJID;
            }

            list.msg = rc;
            list.env_info = &p_childLCinfo->module_info;
            list.newflag = FALSE;
            list.level = symbology.level;
            list.properties = properties;
            list.geometry = NULL;
            list.display = &symbology.display_attr;
            list.class_attr = NULL;
            list.name = NULL;

            omrc = EFplace_nested_plane (
                (IGRlong)count,
                p_childLCinfo,
                &list,
                FALSE,
                my_id,
                &planeId,
                rc
            );

        } /* fi try to construct plane */  

        if (EMSerror (omrc) OR EMSerror (*rc))
        {
            /* errors and did not make plane; move to error layer */

            EMSrc moveRc;

            (void)om$send (
                msg = message ECigdsiems.ECmoveToErrorLayer (
                    &moveRc,
                    *objectInfo,
                    me->current_env.md_id
                ),
                targetid = my_id
            );

#           if ERRORLAYER
            (void)fprintf (stderr, "%d ECcvty2.I %d %d to error layer\n",
                numCalls,
                objectInfo->osnum,
                objectInfo->objid
            );
#           endif

        }
        else if (allClosedAndPlanarCurves)
        {
            /* no errors and made plane:  remove original cell */

            IGRlong deleteRc;
            EMSrc deleteOmrc;

            /* delete the old cell */

            deleteOmrc = om$send (
                msg = message GRgraphics.GRdelete (
                    &deleteRc,
                    &me->current_env
                ),
                targetid = objectInfo->objid,
                targetos = objectInfo->osnum
            );

            objectInfo->objid = planeId; /* return the plane */

            if (hasName) /* if appropriate, name the plane */
            {
                GUputname (rc, name, objectInfo, &me->current_env);

            } /* fi appropriate, name the plane */

        } /* end else no errors and made plane */

        if (p_childGRid) om$dealloc (ptr = p_childGRid);
        if (p_childLCinfo) om$dealloc (ptr = p_childLCinfo);

    } /* fi (try AND EMSokay (omrc) AND EMSokay (*rc)) */

#   if SHOWCALLS
    {
        (void)fprintf (stderr, "%d ECcvty2.I exit\n", numCalls);
    }
#   endif

    return omrc;
}

end implementation ECigdsiems;
