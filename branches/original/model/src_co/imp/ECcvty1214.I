/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*
ALGORITHM

Get a graphic group of my elements via the implementation used by
my ancestor.

Make the graphic group into as few composite curves as possible
-- optimally one, and a closed one in the complex shape case.

HISTORY

06/04/91    DLB Support current_creator.
16 Jan 1991 pp  Added support for CGM translator.
18 Jun 1990 pp  Made a fix wherein shapes were not getting named.
23 Aug 1989 pp  If the object being translated is a complex shape and it
                is not planar then the same is forced to be a plane.
04 Apr 1989 jBk Enhanced conditionally compiled debugging code.
15 Mar 1989 jBk Instead of getting the module environment a la
                the source I have seen for the COcvigdsige
                implementation of cvt_type1214, I now depend upon
                the module environment in me->current_env.
08 Feb 1989 jBk Made minor performance tweak.
18 Jan 1989 jBk Declared GUputname and GUgetname as external.
19 Jul 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.
*/

# include "EMS.h"
# include "transdef.h"

# ifndef ImplementPlane
# define ImplementPlane 0
# endif

# ifndef DEBUG
# define DEBUG 0
# endif

# if DEBUG
#   ifndef SHOWCALLS
#   define SHOWCALLS 1
#   endif
# endif

# ifndef SHOWCALLS
# define SHOWCALLS 0
# endif

# if DEBUG || SHOWCALLS
#   include <stdio.h>
    extern int EFmsgReport ();
# endif

/* GRIS_PLANAR GRIS_NEW GRIS_MODIFIED GRIS_LOCATABLE GRIS_DISPLAYABLE */
#include "godef.h"

/* AND IS EMSokay EMSerror */
# include "EMSlogic.h"

/* EMS_E_NoIntersection EMS_E_Closed */
# include "EMSmsgdef.h"

# if SHOWCALLS
    /* EMSmsgReport */
#   include "EMScmacros.h"
# endif


    /* for go.h */
#   include "igr.h"
#   include "igrdp.h"
#   include "godef.h"
#   include "gr.h"

    /* struct GRprops */
#   include "go.h"

    /* for grio.h */
#   include "igr.h"
#   include "griodef.h"
#   include "go.h"
#   include "ex.h"

#   include "exsysdep.h" /* For compile switch settings */

    /* struct GRlc_info */
#   include "grio.h"

    /* symbology derivation macros */
#   include "EMSigdsmac.h"

    from GRgraphics import GRdelete;
#ifndef IDRAW
    from EMSplane import EMplane_of_curve;
#endif

#   include "emserr.h" /* For EMerr_hndlr */
from GRvg import GRgeomprops;

method cvt_type1214 (IGRlong *rc; struct GRid *object_info)
{
#   if SHOWCALLS
    static staticNumCalls = 0;
#   endif
    EMSrc omrc;
    struct GRvg_construct list;
    struct IGDS_complex *igdscpx;
    IGRint igdstype; /* type of igds element */
    IGRshort igdscount; /* count of elements according to igds */
    IGRboolean has_name;
    IGRchar name[257];


    struct IGRdisplay display;

#   if SHOWCALLS
    int numCalls;

    numCalls = ++staticNumCalls;

    (void)fprintf (stderr, "%d ECcvty1214.I into\n", numCalls);
#   endif

#ifdef BIG_ENDIAN
    GRswap_type1214_ele(me->cvt_bufs.ele_buf);
#endif
    igdscpx = (struct IGDS_complex *)me->cvt_bufs.ele_buf;
    igdstype = me->cvt_bufs.ele_type;
    igdscount = igdscpx->num_elements;

    /* intentional block to set up properties word */
    {
        IGRushort  properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

        if (igdscpx->header.properties & 0x2000)
        {
            properties |= GRIS_PLANAR;
        }
        if (igdscpx->header.properties & 0x0200)
        {
            properties |= GRIS_NEW;
        }
        if (igdscpx->header.properties & 0x0400)
        {
            properties |= GRIS_MODIFIED;
        }

        list.properties = properties;
    }

    list.msg = rc;
    list.env_info = &me->current_env;
    list.newflag = FALSE;
    list.level = igdscpx->header.level & 0x3f;
    list.geometry = NULL;
    list.display = &display;
    list.class_attr = NULL;
    list.name = NULL;



    /* intentional block for getting element name */

/* Begin support for CGM */

    {
        IGRint has_link;
        extern IGRint GUattr_link ();

        /*
            Check the user data linkage for an element name.
        */

        has_link = GUattr_link(rc, &igdscpx->header,name,
                   &igdscpx->header.symbology,NULL,NULL);
        has_name = (has_link & HAS_NAME_TYPE);

        display.color =
           IGDS_SYMBOLOGY_TO_IEMS_COLOR (igdscpx->header.symbology);
        display.weight =
           IGDS_SYMBOLOGY_TO_IEMS_WEIGHT (igdscpx->header.symbology);
        display.style =
           IGDS_SYMBOLOGY_TO_IEMS_STYLE (igdscpx->header.symbology);
    }

/* end support */

    if (EMSokay (*rc))
    {
        omrc = om$send (
            mode = OM_e_wrt_parent,
            msg = message ECigdsiems.cvt_type1214 (
                rc,
                object_info
            ),
            targetid = my_id
        );
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        /*
            Convert group into composite curve

            shape is true iff this is a shape and needs to be
            closed.

            moveToErrorLayer is true iff I cannot properly link
            the components of this string, close this string or
            make a plane of this string.

            okayToName is true iff I at least properly made the
            complex string and thus no longer have the graphic
            group made by the method of my parent -- which took
            its name, if it had one, with it.
        */
        IGRboolean shape;
        IGRboolean moveToErrorLayer = FALSE;
        IGRboolean okayToName = FALSE;

        shape = igdstype IS GU_CPX_SHAPE;

        omrc = om$send (
            msg = message ECigdsiems.ECcomplexString (
                (EMSrc *)rc,
                object_info,
                igdscount,
                shape,      /* oughtClose */
                FALSE,      /* tryToClose */
                &list
            ),
            targetid = my_id
        );
/*
 * If the object in question is a complex shape, then check to see if the
 * same is planar and if it is not planar then project the same onto
 * a least squares plane.
 * pp (08/24/89 )
 */
        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            okayToName = TRUE;
         if (shape)
         {
            struct GRprops propertiesStruct;

            omrc = om$send (
                msg = message GRvg.GRgeomprops (
                    rc,
                    &me->current_env.md_env.matrix_type,
                    me->current_env.md_env.matrix,
                    &propertiesStruct
                ),
                targetid = object_info->objid,
                targetos = object_info->osnum
            );

            if (EMSokay (omrc) AND EMSokay (*rc) AND
                propertiesStruct.phy_closed AND (!propertiesStruct.planar))
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
                 
              moveToErrorLayer = TRUE; /* Only if the operation succeeds is 
                                          this set to FALSE */

              EFgenerate_least_squares_plane(rc,object_info,
               &me->current_env,&pln);
              EMerr_hndlr(!(1&*rc), *rc, MSFAIL, wrapup);

              EFproject_any_curve_on_planen(rc,&list,object_info,
              &me->current_env,&pln,normal_buff,&pln_comp,NULL);
              EMerr_hndlr(!(1&*rc), *rc, MSFAIL, wrapup);

              omrc = om$send (
                     msg = message GRgraphics.GRdelete (
                          rc,
                          &me->current_env
                       ),
                      targetid = object_info->objid,
                      targetos = object_info->osnum
                );

              moveToErrorLayer = FALSE; 
              object_info->objid = pln_comp.objid;
            }
         }
        }

        if (*rc IS EMS_E_NoIntersection OR *rc IS EMS_E_Closed)
        {
            moveToErrorLayer = TRUE;
        }

#       if ImplementPlane

        if (shape AND EMSokay (omrc) AND EMSokay (*rc))
        {
            struct GRprops propertiesStruct;

            omrc = om$send (
                msg = message GRvg.GRgeomprops (
                    rc,
                    &me->current_env.md_env.matrix_type,
                    me->current_env.md_env.matrix,
                    &propertiesStruct
                ),
                targetid = object_info->objid,
                targetos = object_info->osnum
            );

            if (EMSokay (omrc) AND EMSokay (*rc) AND
                propertiesStruct.phy_closed AND propertiesStruct.planar)
            {
                extern OMuword OPP_EMSplane_class_id;
                OM_S_OBJID plane;
                struct GRlc_info cLCinfo;

                list.display = &display;

                cLCinfo.located_obj = *object_info;
                cLCinfo.module_info = me->current_env;
                cLCinfo.proj_pnt[0] = 0;
                cLCinfo.proj_pnt[1] = 0;
                cLCinfo.proj_pnt[2] = 0;
                cLCinfo.geom_parms.u = 0;
                cLCinfo.geom_parms.v = 0;
                cLCinfo.geom_parms.polygon_inx = 0;
                cLCinfo.geom_parms.leaf_id.objid = NULL_OBJID;
                cLCinfo.geom_parms.leaf_id.osnum = object_info->osnum;

                omrc = om$construct(classid = OPP_EMSplane_class_id,
                                    osnum = object_info->osnum,
                                    p_objid = &plane);
                if (1 & omrc)
                {
                  extern OM_S_OBJID current_creator;
                  current_creator = plane;
                  omrc = om$send(msg = message EMSplane.EMplane_of_curve (
                                       rc,         /* EMmsg */
                                       &list,      /* arglist */
                                       &cLCinfo,   /* curve_lcinfo */
                                       NULL,       /* incurve  */
                                       NULL,       /* curve_type */
                                       FALSE,      /* test_degeneracy */
                                       TRUE,       /* construct_loopset */
                                       NULL,       /* orientation_point */
                                       NULL),        /* edgeids */
                                 targetid = plane,
                                 targetos = object_info->osnum);
                  current_creator = NULL_OBJID;
                }

                if (EMSokay (omrc) AND EMSokay (*rc))
                {
                    omrc = om$send (
                        msg = message GRgraphics.GRdelete (
                            rc,
                            &me->current_env
                        ),
                        targetid = object_info->objid,
                        targetos = object_info->osnum
                    );

                    object_info->objid = plane;
                }
                else
                {
                    moveToErrorLayer = TRUE;
                }
            }
        }

#       endif /* ImplementPlane */

        if (has_name AND okayToName)
        {
            EMSrc nameRc;
            extern IGRlong GUputname ();

            GUputname (&nameRc, name, object_info, &me->current_env);
        }

wrapup :

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
    }

    if (EMSokay (*rc))
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
    (void)EMSmsgReport (omrc, "returned omrc", FALSE);
    (void)EMSmsgReport (*rc, "returned *msg", FALSE);
    (void)fprintf (stderr, "%d ECcvty1214.I exit\n", numCalls);
#   endif

    return omrc;
}

end implementation ECigdsiems;
