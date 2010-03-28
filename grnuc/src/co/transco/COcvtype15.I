/*
Name
        COcvigdsige.cvt_type15

Description
        This function converts an IGDS ellipse to an OSA ellipse.  If
        the primary axis and secondary axis are equal then a circle is
        created.  Otherwise an ellipse is created.  The new object will
        be added to the R-tree.

History
        Old.  Very old.

        mrm     03/17/92    Fix call to GRswap_type15_ele to send
                            correct dimension
                03/20/92    Use bastol to determine equality between axes,
                            to prevent "noisy" conversion EMS->IGDS->EMS
                            changing circles to ellipses.
*/

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "bserr.h"

extern IGRboolean MArotmx();

from GRgraphics import GRchgprops;

method cvt_type15(IGRlong *msg; struct GRid *object_info)
{
    static IGRchar	*GUellipse_classes[3] = { "GR2iellipse",
                                                  "GR3iellipse",
                                                  "GR3dellipse" };
    static IGRchar	*GUcircle_classes[3] = { "GR2icircle",
                                                 "GR3icircle",
                                                 "GR3dcircle" };
    IGRchar		class_name[80];	        /* class name for object     */
    IGRchar		*class_attr;
    IGRchar		name[257];              /* element's name	     */
    IGRshort		set = 1;
    IGRshort		props;
    IGRchar		*typeface = NULL;
    IGRchar		*charmap = NULL;
#ifdef BIG_ENDIAN
    IGRshort		dim;
#endif
    IGRshort		i;                      /* loop counter		     */
    IGRboolean		maret;                  /* MA function return status */
    IGRint		has_link;
    IGRlong		status;
    IGRlong		*internal_pntr;
    IGRlong		no_floats;
    IGRlong		temp_int;
    IGRdouble           bastol;
    IGRdouble		rot_angle;
    IGRdouble		quaternions[4];
    IGRdouble		poles[21];
    IGRdouble		knots[10];
    IGRdouble		weights[7];
    IGRvector		vector;
    struct IGRellipse	ellipse;
    struct IGRbsp_curve	*bspellipse;
    struct IGDS_ellipse	*igdsellipse;
    struct GUcommon_header_info element;        /* GUgetname info	     */

    /*
     *  Cast element buffer.
     */

    igdsellipse =(struct IGDS_ellipse *) me->cvt_bufs.ele_buf;

    /* convert to native format */

#ifdef BIG_ENDIAN
    dim = (me->IGDS_file_type == GU_2I) ? 2 : 3;
    GRswap_type15_ele(me->cvt_bufs.ele_buf,dim);
#endif

    /*
     *  initialize pointer to rotation information
     *  which is followed by origin of ellipse
     */
 
    internal_pntr = &igdsellipse->ellipse.rot_org;

    if (me->IGDS_file_type == GU_2I)
    {
        /*
         *  2-D ellipse
         */

        GUswapint(internal_pntr, &temp_int);

        if (temp_int < 0)
        {
            temp_int = -(0x7fffffff & temp_int);
        }
        rot_angle =(temp_int / 360000.0) *(PI /180.0);

        ++internal_pntr;

        vector[0] = 0;
        vector[1] = 0;
        vector[2] = 1;
        
        /*
         *  convert rotation angle to rotation matrix
         */

        maret = MArotmx(msg, vector, &rot_angle, ellipse.rot_matrix);

        if (!(maret & 1))
        {
            /*
             *  error creating rotation matrix
             *  exit 
             */
        }

        no_floats = 2;
        ellipse.origin[2] = GUACT_Z_2D;

    }
    else
    {
        for (i = 0; i < 4; ++i)
        {
            GUswapint(internal_pntr, &temp_int);
            quaternions[i] = (IGRdouble) temp_int;
            ++internal_pntr;
        }
    
        /*
         *  convert quaternions to rotation matrix
         */

        GUquat_to_rotmx(quaternions, ellipse.rot_matrix);
        no_floats = 3;
    }

    /*
     *  convert origin
     */

    fltvax_to_flt32(no_floats, internal_pntr, ellipse.origin);

    /*
     *  convert primary axis and secondary axis 
     */

    no_floats = 2;
    fltvax_to_flt32(no_floats, igdsellipse->ellipse.primary, 
                    &ellipse.prim_axis);

    /*
     *  convert the ellipse to a B-spline
     */

    bspellipse =(struct IGRbsp_curve *) me->cvt_bufs.bs_buf;

    bspellipse->poles = poles;
    bspellipse->knots = knots;
    bspellipse->weights = weights;

    status = MAeltobc(msg, &ellipse, bspellipse);

    /*
     *  Set up class name for new OSA object.
     */

    BSEXTRACTPAR(msg, BSTOLBASIS, bastol);

    if ((ellipse.prim_axis - ellipse.sec_axis) < bastol)
    {
        strcpy(class_name, GUcircle_classes[me->object_type]);
    }
    else
    {
        strcpy(class_name, GUellipse_classes[me->object_type]);
    }

    class_attr = NULL;

    /*
      Check the user data linkage for an element name.
    */
    element = igdsellipse->header;
    has_link = GUattr_link(msg, &igdsellipse->header, name,
                           &igdsellipse->header.symbology, typeface, charmap);

    /* 
     *  Construct OSA object.
     */

    status = GUconstruct(me->cvt_bufs.bs_buf, object_info, 
                         class_name, &igdsellipse->header.level,
                         &igdsellipse->header.symbology,
                         &igdsellipse->header.properties, class_attr,
                         &me->scale_factor, &me->current_env);

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
