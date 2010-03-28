/*
Name
        cvt_type1113

Description
        This function converts an IGDS curve to an OSA B-spline curve.
        The new object will be added to the R-tree.  If B-splines are
        not present in the executable, stroked linestrings will be
        constructed.

History
        mrm     03/13/92    fixed call to GRswap_type1113_ele
*/

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "OMmacros.h"
#include "gocmacros.h"

from GRgraphics import GRchgprops;

extern IGRboolean       MAbccopy();
extern IGRboolean       MAcstobez();
extern IGRboolean       MAcspoly();
extern IGRboolean       MAcsgenhist();
extern IGRboolean       MAcsupdhist();
extern IGRboolean       MAbcpyeval();
extern IGRboolean       MApytobc();
extern void		BScomb2cvs();
extern void		BSarclnparc();

method cvt_type1113 (IGRlong *msg; struct GRid *object_info)
{
    static IGRchar	*GUcrv_classes[3] = { "GR2ibcsubbc",
                                              "GR3ibcsubbc",
                                              "GRbcsubbc"    };
    static IGRchar	*GUlinestr_classes[3] = { "GR2ilinestr",
                                                  "GR3ilinestr",
                                                  "GR3dlinestr"    };
    IGRchar		*typeface = NULL;
    IGRchar		*charmap = NULL;
    IGRchar		class_name[80];	/* class name for object     */
    IGRchar		name[257]; /* element's name	     */
    IGRshort		i,j;    /* loop counter		     */
    IGRshort		set = 1;
    IGRshort		props;
    IGRshort		total_coords;
    IGRshort		ndices;
#ifdef BIG_ENDIAN
    IGRshort            direc = GRVaxToSparc;
#endif
    OMuword		classid;
    IGRboolean		stroke = FALSE;
    IGRboolean		placed = FALSE;
    IGRint		has_link;
    IGRlong		status = 0;
    IGRlong		bsmess;
    IGRlong		int_points[303];
    IGRlong             temp_int;
    IGRlong		n = 4;
    IGRdouble		flt_points[303];
    IGRdouble		u1 = 0.0,u2 = 1.0;
    IGRdouble		points[12];
    IGRdouble		poles[12];
    IGRdouble		knots[8];
    IGRdouble		cv1_poles[1212];
    IGRdouble		cv1_knots[408];
    IGRdouble		cv2_poles[1212];
    IGRdouble		cv2_knots[408];
    IGRdouble		dist_table[5];
    IGRdouble		tangent_table[6];
    IGRdouble		slope_table[15];
    IGRdouble		cubic_polys[12];
    IGRdouble		max;
    struct IGRbsp_curve	*cv1 = NULL, *cv2 = NULL, *temp;
    struct IGRbsp_curve	temp_curve, curve1, curve2;
    struct IGRpolyline  polyline;
    struct IGDS_curve	*igdscurve;
    struct IGResbc	class_attr;
    struct GUcommon_header_info element; /* GUgetname info	     */

    /*
     *  initialize variables
     */
    if (me->IGDS_file_type == GU_2I)
    {
        ndices = 2;
    }
    else
    {
        ndices = 3;
    }	

#ifdef BIG_ENDIAN
    GRswap_type1113_ele(me->cvt_bufs.ele_buf, ndices, direc);
#endif

    igdscurve = (struct IGDS_curve *)me->cvt_bufs.ele_buf;

    /*
     *  Check for invalid type 11 elements - The number of points
     *  should atleast be = 7, as 3 is the minimum that may be
     *  placed and the system adds 4 additional points in IGDS.
     */
	
    if (igdscurve->curve.num_points < 7)
    {
        goto wrapup;
    }

    class_attr.is_polydis = FALSE;
    class_attr.is_curvedis = TRUE;

    /*
     * Set up curves
     */

    curve1.poles = cv1_poles;
    curve1.knots = cv1_knots;
    curve1.weights = NULL;
    curve1.num_boundaries = 0;
    curve1.bdrys = NULL;

    curve2.poles = cv2_poles;
    curve2.knots = cv2_knots;
    curve2.weights = NULL;
    curve2.num_boundaries = 0;
    curve2.bdrys = NULL;

    /*
     *  move coordinate values from IGDS formatted
     *  buffer to OSA formatted buffer
     */

    if (me->IGDS_file_type == GU_2I)
    {
        /*
         *  2-D file
         */

        ndices = 2;
        total_coords = igdscurve->curve.num_points * 2;
        OM_BLOCK_MOVE(&(igdscurve->curve.pnts_ptr), int_points,
                      total_coords*4);
        i = j = 0;
        while (i < total_coords)
        {
            GUswapint (&int_points[i], &temp_int);
            flt_points[j] = (IGRdouble) temp_int;
            ++i;
            ++j;
            GUswapint (&int_points[i], &temp_int);
            flt_points[j] = (IGRdouble) temp_int;
            ++i;
            ++j;
            flt_points[j++] = GUACT_Z_2D;
        }		
    }
    else
    {
        /*
         *  3-D file type
         */

        ndices = 3;
        total_coords = igdscurve->curve.num_points * 3;
        OM_BLOCK_MOVE(&(igdscurve->curve.pnts_ptr), int_points,
                      total_coords*4);
        for (i=0; i<total_coords; ++i)
        {
            GUswapint (&int_points[i], &temp_int);
            flt_points[i] = (IGRdouble) temp_int;
        }
    }

    status = om$get_classid(classname = GUcrv_classes[me->object_type],
                            p_classid = &classid);

    if (1 & status)
    {
        strcpy (class_name, GUcrv_classes[me->object_type]);
    }
    else
    {
        strcpy (class_name, GUlinestr_classes[me->object_type]);
        stroke = TRUE;
        polyline.num_points = 4;
        polyline.points = points;
    }

    /*
     *  convert IGDS curve to OSA B-spline curve
     */

    temp_curve.poles = poles;
    temp_curve.knots = knots;
    temp_curve.weights = NULL;
    temp_curve.num_boundaries = 0;
    temp_curve.bdrys = NULL;


    status = MAcsgenhist (msg, &flt_points[0], dist_table,
                          slope_table, tangent_table);

    for (i=2; i < igdscurve->curve.num_points - 3; ++i)
    {
        status = MAcspoly (msg, &flt_points[i * 3], dist_table,
                           tangent_table, cubic_polys);

        MA2ptdis (msg, &flt_points[i*3], &flt_points[i*3+3], &max);

        status = MAcstobez (msg, cubic_polys, &max, &temp_curve);
	
        if (stroke)
        {
            MAbcpyeval (msg, &temp_curve, &u1, &u2, &n, &polyline);
            MApytobc (msg, &polyline, &temp_curve);
        }

        if (i != (igdscurve->curve.num_points - 3) - 1)
        {
            status = MAcsupdhist (msg, &flt_points[(i+3)*3], 
                                  &flt_points[(i+4)*3], dist_table,
                                  slope_table, tangent_table);
        }

        if (!placed)
        {
            MAbccopy(msg, &temp_curve, &curve1);
            cv1 = &curve1;
            cv2 = &curve2;
            placed = TRUE;
        }
        else
        {
            BScomb2cvs(cv1, &temp_curve, cv2, &bsmess);
            temp = cv1;
            cv1 = cv2;
            cv2 = temp;
        }
    }

    /* 
     *  reparameterize curve so that knots are arc length-distributed.
     */
    BSarclnparc(&bsmess, cv1);


    /*
      Check the user data linkage for attribute linkages
      */

    element = igdscurve->header;
    has_link = GUattr_link (msg, &igdscurve->header, name,
                            &igdscurve->header.symbology, typeface, charmap);

    /*
     *  construct the curve
     */

    status = GUconstruct(cv1, object_info, class_name,
                         &igdscurve->header.level, 
                         &igdscurve->header.symbology,
                         &igdscurve->header.properties,
                         &class_attr, &me->scale_factor,
                         &me->current_env);


    if (has_link & HAS_FILLED_TYPE)
    {
        props = 0;
        props |= GRFILLED_DISPLAY;
        status = om$send (msg = message GRgraphics.GRchgprops (msg, &set,
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

  wrapup:
    return(status);
}

end implementation COcvigdsige;
