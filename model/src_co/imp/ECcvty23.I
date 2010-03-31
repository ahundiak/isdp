/* ###################   APOGEE COMPILED   ################## */
class implementation ECigdsiems;

/*

NOTE

Currently, this implementation does not make any special effort
for the degenerate, planar cone or cylinder.

HISTORY

06/04/91    DLB Support current_creator.
18 Jan 1991 pp  Added support for CGM translator.
04 Apr 1989 jBk Added code to move a surface which is a failed
                solid to the error layer.

                Changed environment sent in EMcap_thyself
                messages.  It ought not be scaled.  It is very
                likely there are now some HUGE planes and
                uncapped type-23's out there in I/EMS files
                translated from IGDS.

                Enhanced conditionally compiled debugging code.

08 Feb 1989 jBk Made minor performance tweak.

18 Jan 1989 jBk Declared GUputname and GUgetname as external.

02 Aug 1988 jBk Genesis.  Implemented in I/EMS 1.1.2 for 1.2.0.

Sudha   06/02/93        modified to include for BSprototype headers

*/

# include "EMS.h"

# ifndef DEBUG
# define DEBUG 0
# endif

# if DEBUG
#   ifndef TRYINGSOLID
#   define TRYINGSOLID 0
#   endif

#   ifndef SHOWCALLS
#   define SHOWCALLS 0
#   endif
# endif

# ifndef TRYINGSOLID
# define TRYINGSOLID 0
# endif

# ifndef SHOWCALLS
# define SHOWCALLS 0
# endif

# if DEBUG || TRYINGSOLID || SHOWCALLS
#   include <stdio.h>
    /* EMSmsgReport */
#   include "EMScmacros.h"
# endif

/* OM_BLOCK_MOVE */
# include "OMmacros.h"

/* GRIS_PLANAR GRIS_NEW GRIS_MODIFIED GRIS_LOCATABLE GRIS_DISPLAYABLE */
# include "godef.h"

/* BSrc BSERROR */
# include "bserr.h"

/* AND EMSokay */
# include "EMSlogic.h"

/* kinds of type 23 elements */
# include "EMSigdsdef.h"

/* extraction macros for type word of type 23 */
# include "EMSigdsmac.h"

/* struct EMSradius */
# include "EMSstruct.h"

/* compile switch settings */
# include "exsysdep.h"

#include "matypemx.h"
#include "mamulmx.h"
#include "bsmkvec.h"

from EMSsfsolid import EMcap_thyself;
from EMScone import EMcone;
from EMScylindr import EMcylinder_by_axis_n_radius;
from EMSelpcone import EMconstruct_elliptical_cone;

method cvt_type23 (IGRlong *rc; struct GRid *object_info)
{
    EMSrc omrc;
    struct GRmd_env scaled_envi;
    IGRboolean has_name;
    IGRchar name[257];
    struct GRvg_construct list;
    struct IGRdisplay display;
    struct IGDS_cone *igdscone;
    int madeSurface = FALSE;
    int moveToErrorLayer = FALSE;

#   if SHOWCALLS
    static int staticNumCalls = 0;
    int numCalls;

    numCalls = ++staticNumCalls;
    (void)fprintf (stderr, "%d ECcvty23.I into\n", numCalls);
#   endif

    /*
        Cast my element buffer as the IGDS element cone structure.
    */

#ifdef BIG_ENDIAN
    GRswap_type23_ele(me->cvt_bufs.ele_buf);
#endif
    igdscone = (struct IGDS_cone *) me->cvt_bufs.ele_buf;

    /* intentional block to set up properties word */
    {
        IGRushort  properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

        if (igdscone->header.properties & 0x2000)
        {
            properties |= GRIS_PLANAR;
        }
        if (igdscone->header.properties & 0x0200)
        {
            properties |= GRIS_NEW;
        }
        if (igdscone->header.properties & 0x0400)
        {
            properties |= GRIS_MODIFIED;
        }

        list.properties = properties;
    }

    list.msg = rc;
    list.env_info = &scaled_envi;
    list.newflag = FALSE;
    list.level = igdscone->header.level & 0x3f;
    list.geometry = NULL;
    list.display = &display;
    list.class_attr = NULL;
    list.name = NULL;

    /*
        I lifted the following three assignments from I/Draft's
        GUconstruct function, and modified them to fit here and
        to use my mnemonic macros.
    */

/*
    display.color =
        IGDS_SYMBOLOGY_TO_IEMS_COLOR (igdscone->header.symbology);
    display.weight =
        IGDS_SYMBOLOGY_TO_IEMS_WEIGHT (igdscone->header.symbology);
    display.style =
        IGDS_SYMBOLOGY_TO_IEMS_STYLE (igdscone->header.symbology);
*/

    /* scale module env */

    /* intentional block for getting and scaling module environment */
    {
        IGRmatrix scale_matrix;
        IGRdouble *sm = &scale_matrix[0];
        int ss = 15;
        IGRshort num_rc = 4;

        scaled_envi.md_id = me->current_env.md_id;

        do
        {
            *sm++ = 0.0;
        } while (ss--);

        scale_matrix[0] = me->scale_factor;
        scale_matrix[5] = me->scale_factor;
        scale_matrix[10] = me->scale_factor;
        scale_matrix[15] = 1.0;

        MAmulmx (
            rc,
            &num_rc,
            &num_rc,
            &num_rc,
            me->current_env.md_env.matrix,
            scale_matrix,
            scaled_envi.md_env.matrix
        );
    }

    /* get matrix type */

    if (EMSokay (*rc)) /* if scaled matrix okay */
    {

        MAtypemx (
            rc,
            scaled_envi.md_env.matrix,
            &scaled_envi.md_env.matrix_type
        );
    }


/*
    if (EMSokay (*rc)) 
    {
        extern IGRboolean GUgetname ();

        has_name = GUgetname (rc, &igdscone->header, name);
    }
*/

/* Begin support for CGM */

    if (EMSokay (*rc))
    {
        IGRint has_link;
        extern IGRint GUattr_link ();

        /*
            Check the user data linkage for an element name.
        */

        has_link = GUattr_link(rc, &igdscone->header,name,
                   &igdscone->header.symbology,NULL,NULL);
        has_name = (has_link & HAS_NAME_TYPE);

        display.color =
           IGDS_SYMBOLOGY_TO_IEMS_COLOR (igdscone->header.symbology);
        display.weight =
           IGDS_SYMBOLOGY_TO_IEMS_WEIGHT (igdscone->header.symbology);
        display.style =
           IGDS_SYMBOLOGY_TO_IEMS_STYLE (igdscone->header.symbology);
    }

/* end support */

    /* do the construction */

    if (EMSokay (*rc)) /* if checked name okay */
    {
        /* GUswapint is a macro defined in transmacros.h */
        extern /* defaults to int */ int GUquat_to_rotmx ();
        extern /* I know not the type */ fltvax_to_flt32 ();
        OMuword kind;
        struct IGRcone cone;
        IGRdouble quaternions[4];
        IGRchar *conedata;
        IGRlong cone_array[16];

        /*
            The code from this point until the comment which
            reads "end lift" was pretty much lifted from the
            COcvigdsige.cvt_type23 implementation.
        */ 

        /* initialize pointer to cone information */
 
        conedata = &igdscone->cone_data;

        /*
            Extract quaternions from the IGDS element and form
            the rotation matrix from them. 
        */

        /* intentional block for declaration of ii */
        {
            int ii;

            for (ii = 0; ii < 4; ++ii )
            {
                IGRlong temp_long, long_quat;

                OM_BLOCK_MOVE (conedata, &temp_long, 4);

                GUswapint (&temp_long, &long_quat);
                quaternions[ii] = (IGRdouble) long_quat;
                conedata += 4;
            }
        }
    
        GUquat_to_rotmx (quaternions, cone.rot_matrix);

        OM_BLOCK_MOVE (conedata, cone_array, 64);

        /* convert base origin */

        fltvax_to_flt32 (3, cone_array, cone.base_origin);

        /* convert base radius */

        fltvax_to_flt32 (1, &(cone_array[6]), &cone.base_radius);

        /* convert top origin */

        fltvax_to_flt32 (3, &(cone_array[8]), cone.top_origin);

        /* convert top radius */

        fltvax_to_flt32 (1, &(cone_array[14]), &cone.top_radius);

        /* perform the correct kind of construction */

        /* end lift */

        object_info->osnum = scaled_envi.md_id.osnum;

        kind = IGDS_EXTRACT_KIND_OF_TYPE_23 (igdscone->cone_type);

#       if DEBUG
        (void)fprintf (stderr, "kind is %d\n", kind);
        {
            int mm;

            for (mm = 0; mm < 3; mm++) (void)fprintf (stderr,
                "cone.base_origin[%d] is %lg\n",
                mm, cone.base_origin[mm]);
            (void)fprintf (stderr, "cone.base_radius is %lg\n",
                cone.base_radius);
            for (mm = 0; mm < 3; mm++) (void)fprintf (stderr,
                "cone.top_origin[%d] is %lg\n",
                mm, cone.top_origin[mm]);
            (void)fprintf (stderr, "cone.top_radius is %lg\n",
                cone.top_radius);
            for (mm = 0; mm < 16; mm++) (void)fprintf (stderr,
                "%lg%s", cone.rot_matrix[mm], (mm + 1) % 4 ? " " : "\n");
            for (mm = 0; mm < 16; mm++) (void)fprintf (stderr,
                "%lg%s", scaled_envi.md_env.matrix[mm],
                (mm + 1) % 4 ? " " : "\n");
        }
#       endif

        switch (kind)
        {
        case IGDS_GU_CIRC_TRUNC_CONE_right_cylinder:
        {
            extern OMuword OPP_EMScylindr_class_id;
            struct EMSradius S_radius;

            S_radius.input.value = cone.base_radius;
            S_radius.select = 0;

            omrc = om$construct (
                classid = OPP_EMScylindr_class_id,
                msg = message EMScylindr.EMcylinder_by_axis_n_radius (
                    &list               /* arglist */,
                    cone.base_origin    /* pnt1 */,
                    cone.top_origin     /* pnt2 */,
                    &S_radius           /* radius */
                ),
                osnum = scaled_envi.md_id.osnum,
                p_objid = &object_info->objid
            );
        }
        break;

        case IGDS_GU_CIRC_TRUNC_CONE_right_cone:
        case IGDS_GU_CIRC_TRUNC_CONE_right_truncated_cone:
        {
            extern OMuword OPP_EMScone_class_id;
            IGRdouble radii[2];
            IGRpoint axis[2];
            int tt = 2;

            do
            {
                axis[0][tt] = cone.base_origin[tt];
                axis[1][tt] = cone.top_origin[tt];
            } while (tt--);

            radii[0] = cone.base_radius;
            radii[1] = cone.top_radius;

            omrc = om$construct (
                classid = OPP_EMScone_class_id,
                msg = message EMScone.EMcone (
                    (IGRint *)rc                  /* rc */,
                    &list               /* arglist */,
                    axis                /* points */,
                    radii               /* radius */
                ),
                osnum = scaled_envi.md_id.osnum,
                p_objid = &object_info->objid
            );

#           if DEBUG
            {
                extern int EFmsgReport ();

                EFmsgReport (NULL, omrc, "kind 5 omrc");
                EFmsgReport (NULL, *rc, "kind 5 rc");
            }
#           endif
        }
        break;

        case IGDS_GU_CIRC_TRUNC_CONE_cylinder:
        case IGDS_GU_CIRC_TRUNC_CONE_general:
        case IGDS_GU_CIRC_TRUNC_CONE_cone:
        case IGDS_GU_CIRC_TRUNC_CONE_truncated_cone:
        {
            /* these are the potentially skew cases */

            IGRdouble scale;
            IGRvector heightvec; /* height vector of cone */
            IGRvector vec[2]; /* major and minor axis vectors */
#           define major_axis 0
#           define minor_axis 1
            OMuword classid;

            switch (kind)
            {
            case IGDS_GU_CIRC_TRUNC_CONE_cylinder:
            {
                extern OMuword OPP_EMSelpcyl_class_id;

                classid = OPP_EMSelpcyl_class_id;
                scale = 1.0;
            }
            break;

            case IGDS_GU_CIRC_TRUNC_CONE_general:
            case IGDS_GU_CIRC_TRUNC_CONE_cone:
            case IGDS_GU_CIRC_TRUNC_CONE_truncated_cone:
            {
                extern OMuword OPP_EMSelpcone_class_id;

                classid = OPP_EMSelpcone_class_id;
                scale = cone.top_radius / cone.base_radius;
            }
            /* no break; */
            /* no default: */
            }

            /* intentional block of BS */
            {
                BSrc bsrc;

                (void)BSmkvec (
                    &bsrc,
                    heightvec,
                    cone.base_origin,
                    cone.top_origin
                );

                if (BSERROR (bsrc)) *rc = MSFAIL;
            }

            /* end intentional block of BS */

            if (EMSokay (*rc)) /* if BS okay */
            {
                int uu = 2;

                do
                {
                    vec[0][uu] =
                        cone.base_radius * cone.rot_matrix[uu*4];
                    vec[1][uu] =
                        cone.base_radius * cone.rot_matrix[uu*4+1];
                } while (uu--);

#               if DEBUG
                {
                    (void)fprintf (stderr, "vec[0] is %lg %lg %lg\n",
                        vec[0][0], vec[0][1], vec[0][2]);
                    (void)fprintf (stderr, "vec[1] is %lg %lg %lg\n",
                        vec[1][0], vec[1][1], vec[1][2]);
                    (void)fprintf (stderr, "hvc[1] is %lg %lg %lg\n",
                        heightvec[0], heightvec[1], heightvec[2]);
                }
#               endif

                /* construct cylinder/cone */

                omrc = om$construct (
                    classid = classid,
                    msg = message EMSelpcone.EMconstruct_elliptical_cone (
                        rc                  /* EMmsg */,
                        &list               /* construct_list */,
                        cone.base_origin    /* base_center */,
                        vec[major_axis]     /* major_axis */,
                        vec[minor_axis]     /* minor_axis */,
                        heightvec           /* height */,
                        scale               /* scale */
                    ),
                    osnum = scaled_envi.md_id.osnum,
                    p_objid = &object_info->objid
                );

#               if DEBUG
                {
                    extern int EFmsgReport ();

                    EFmsgReport (NULL, omrc, "kind ecn omrc");
                    EFmsgReport (NULL, *rc, "kind ecn rc");
                }
#               endif

            } /* fi BS okay */

            /* end these are the potentially skew cases */
        }
        break;

        default:
            *rc = MSFAIL;
        } /* end switch on IGDS_EXTRACT_KIND_OF_TYPE_23 */
    } /* fi do the construction */

#   if TRYINGSOLID
    (void)fprintf (stderr, "type 23 cone_type is 0x%x is_solid is %d\n",
        igdscone->cone_type,
    IGDS_EXTRACT_TYPE_23_IS_SOLID (igdscone->cone_type));
    EFmsgReport (NULL, omrc, "pre-capping omrc");
    EFmsgReport (NULL, *rc, "pre-capping *msg");
#   endif

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        /* made surface */

        madeSurface = TRUE;

        if (IGDS_EXTRACT_TYPE_23_IS_SOLID (igdscone->cone_type))
        {
            /* igds element is solid */

            extern OMuword OPP_EMSsfsolid_class_id;
            GRobjid solid;

#           if TRYINGSOLID
            (void)fprintf (stderr, "Trying to cap solid\n");
#           endif

            /* no scaling necessary so use normal env */

            list.env_info = &me->current_env;

            omrc = om$construct(classid = OPP_EMSsfsolid_class_id,
                                osnum = object_info->osnum,
                                p_objid = &solid);
            if (1 & omrc)
            {
              extern OM_S_OBJID current_creator;
              current_creator = solid;
              omrc = om$send(msg = message EMSsfsolid.EMcap_thyself(rc,
                                   &list, &object_info->objid),
                             targetid = solid,
                             targetos = object_info->osnum);
              current_creator = NULL_OBJID;
            }                             

#           if TRYINGSOLID
            EFmsgReport (NULL, omrc, "capping omrc");
            EFmsgReport (NULL, *rc, "capping *msg");
#           endif

            if (EMSokay (omrc) AND EMSokay (*rc))
            {
                object_info->objid = solid;
            }
            else
            {
                moveToErrorLayer = TRUE;
            }
        } /* fi igds element is solid */
    } /* fi made surface */

    /* if it is supposed to have a name, name the result */

    if (has_name AND madeSurface)
    {
        extern IGRlong GUputname ();
        EMSrc nameRc;

        GUputname (&nameRc, name, object_info, &me->current_env);

        if (EMSokay (*rc)) *rc = nameRc;
    }

    if (moveToErrorLayer)
    {
        EMSrc mvrc, mvomrc;

        mvomrc = om$send (
            msg = message ECigdsiems.ECmoveToErrorLayer (
                &mvrc,
                *object_info,
                me->current_env.md_id
            ),
            targetid = my_id
        );

        /* assignment of mvomrc is solely to avoid a (void) typecast */
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
    (void) EMSmsgReport (omrc, "ECcvty23.I returned omrc", FALSE);
    (void) EMSmsgReport (*rc, "ECcvty23.I returned *msg", FALSE);
    (void)fprintf (stderr, "%d ECcvty23.I exit\n", numCalls);
#   endif

    return omrc;
}

end implementation ECigdsiems;
