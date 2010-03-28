/*
Name
        COcvigdsige.cvt_type16

Description
        This function converts an IGDS arc to an OSA arc.  If the
        primary axis and secondary axis are equal then a circular arc is
        created.  Otherwise an elliptical arc is created.  The new
        object will be added to the R-tree.

History
        Old.  Very old.

        mrm     03/17/92    Fix call to GRswap_type15_ele to send
                            correct dimension
                03/20/92    Use bastol to determine equality between axes,
                            to prevent "noisy" conversion EMS->IGDS->EMS
                            changing circular arcs to elliptical arcs.
*/

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "bserr.h"

from GRgraphics import GRchgprops;

extern IGRboolean MArotmx();

method cvt_type16(IGRlong *msg; struct GRid *object_info)
{
    static IGRchar	*GUc_arc_classes[3] = {"GR2icirarc",
                                               "GR3icirarc",
                                               "GR3dcirarc" };
    static IGRchar	*GUe_arc_classes[3] = {"GR2iellarc",
                                               "GR3iellarc",
                                               "GR3dellarc" };
    IGRchar		class_name[32];	        /* class name for object     */
    IGRchar		*class_attr;
    IGRchar		name[257];              /* element's name	     */
    IGRchar		*typeface = NULL;
    IGRchar		*charmap = NULL;
    IGRshort		set = 1;
    IGRshort		props;
#ifdef BIG_ENDIAN
    IGRshort		dim;
#endif
    IGRboolean		maret;                  /* MA function return status */
    IGRint		has_link;
    IGRint  		i;                      /* loop counter		     */
    IGRlong		status;
    IGRlong		*internal_pntr;
    IGRlong		no_floats;
    IGRlong		temp_int;
    IGRlong             intbuf[4];
    IGRdouble           bastol;
    IGRdouble		rot_angle;
    IGRdouble		quaternions[4];
    IGRdouble		poles[21];
    IGRdouble		knots[10];
    IGRdouble		weights[7];
    IGRvector		vector;
    struct IGRarc	arc;
    struct IGRbsp_curve	*bsparc;
    struct IGDS_arc 	*igdsarc;
    struct GUcommon_header_info element;        /* GUgetname info	     */

    igdsarc = (struct IGDS_arc *)me->cvt_bufs.ele_buf;

#ifdef BIG_ENDIAN
    dim = (me->IGDS_file_type == GU_2I) ? 2 : 3;
    GRswap_type16_ele(me->cvt_bufs.ele_buf, dim);
#endif

    /*
     *  initialize pointer to rotation information
     *  and followed by origin of arc
     */
 
    internal_pntr = &igdsarc->arc.rot_org;

    if (me->IGDS_file_type == GU_2I)
    {
        /*
         *  2-D arc
         */

        GUswapint(internal_pntr, &temp_int);

        if (temp_int < 0)
        {
            temp_int = - (0x7fffffff & temp_int);
        }
        rot_angle = (temp_int / 360000.0) * (PI / 180.0);

        ++internal_pntr;

        vector[0] = 0;
        vector[1] = 0;
        vector[2] = 1;
        
        /*
         *  convert rotation angle to rotation matrix
         */

        maret = MArotmx(msg, vector, &rot_angle, arc.rot_matrix);

        no_floats = 2;
        arc.origin[2] = GUACT_Z_2D;	
    }
    else
    {
        /* convert the quaternions from VAX int to native double format */

        for (i = 0; i < 4; ++i, ++internal_pntr)
        {
            GUswapint(internal_pntr, &intbuf[i]);
        }
    
        quaternions[0] = (IGRdouble)intbuf[0];
        quaternions[1] = (IGRdouble)intbuf[1];
        quaternions[2] = (IGRdouble)intbuf[2];
        quaternions[3] = (IGRdouble)intbuf[3];

        /*
         *  convert quaternions to rotation matrix
         */

        GUquat_to_rotmx(quaternions, arc.rot_matrix);
        no_floats = 3;
    }

    /*
     *  convert origin
     */

    fltvax_to_flt32(no_floats, internal_pntr, arc.origin);

    /*
     *  convert primary axis and secondary axis 
     */

    no_floats = 1;
    fltvax_to_flt32(no_floats, igdsarc->arc.primary, &arc.prim_axis);
    fltvax_to_flt32(no_floats, igdsarc->arc.secondary, &arc.sec_axis);

    /*
     *  convert start and sweep angles
     */

    GUswapint(&(igdsarc->arc.start), &temp_int);

    if (temp_int < 0)
    {
        temp_int = -(0x7fffffff & temp_int);
    }
    arc.start_angle = (IGRdouble)((temp_int / 360000.0) * (PI / 180.0));

    GUswapint(&(igdsarc->arc.sweep), &temp_int);

    if (temp_int < 0)
    {
        temp_int = -(0x7fffffff & temp_int);
    }
    if (temp_int == 0)
    {
        arc.sweep_angle = 2 * PI;
    }
    else
    {
        arc.sweep_angle = (IGRdouble)((temp_int / 360000.0) * (PI / 180.0));
    }
    
    /*
     *  convert the arc to a B-spline
     */

    bsparc = (struct IGRbsp_curve *) me->cvt_bufs.bs_buf;

    bsparc->poles = poles;
    bsparc->knots = knots;
    bsparc->weights = weights;

    status = MAartobc(msg, &arc, bsparc);

    BSEXTRACTPAR(msg, BSTOLBASIS, bastol);

    if ((arc.prim_axis - arc.sec_axis) < bastol)
    {
        strcpy(class_name, GUc_arc_classes[me->object_type]);
    }
    else
    {
        strcpy(class_name, GUe_arc_classes[me->object_type]);
    }

    class_attr = NULL;

    /* Check the user data linkage for an element name. */

    element = igdsarc->header;
    has_link = GUattr_link(msg, &igdsarc->header, name, 
                           &igdsarc->header.symbology, typeface, charmap);

    /*
     *  Construct an OSA object.
     */

    status = GUconstruct(me->cvt_bufs.bs_buf, object_info, 
                         class_name, &igdsarc->header.level,
                         &igdsarc->header.symbology, &igdsarc->header.properties,
                         class_attr, &me->scale_factor, &me->current_env);

    if (has_link & HAS_FILLED_TYPE)
    {
        props = 0;
        props |= GRFILLED_DISPLAY;
        status = om$send(msg = message GRgraphics.GRchgprops(msg, &set,
                                                             &props),
                         targetid = object_info->objid,
                         targetos = object_info->osnum);
    }

    /* 
     *  Enter the IGDS element's name into the translated element's
     *  data structure.
     */
    if (has_link & HAS_NAME_TYPE)
    {
        GUputname(msg, name, object_info, &me->current_env);
    }

    return(status);

}

end implementation COcvigdsige;
