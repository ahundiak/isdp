/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function  converts an IGDS line to an OSA line.
 *  If the H-bit in the properties word is set, then an
 *  OSA infinite line is created; otherwise, an OSA
 *  line segment is created.  The new object will be
 *  added to the R-tree.  Zero-length lines are converted
 *  to 'point' objects.
 */


class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "OMmacros.h"
#include "gocmacros.h"

from GRgraphics import GRchgprops;

method cvt_type3 (IGRlong *msg; struct GRid *object_info)

{
	struct IGDS_line	*igdsline;

	static IGRchar		*GUpoint_classes[3] = { "GR2ipoint",
							"GR3ipoint",
							"GR3dpoint"};

	static IGRchar		*GUinfline_classes[3] = { "GR2iinfline",
							  "GR3iinfline",
							  "GR3dinfline" };

	static IGRchar		*GUlineseg_classes[3] = { "GR2ilineseg",
							  "GR3ilineseg",
							  "GR3dlineseg" };

	IGRchar			class_name[80];	/* class name for object     */
	IGRshort		i,j;		/* loop counter		     */
	IGRlong			total_coords;	/* total coordinates in shape*/
	IGRlong			points[6];
        IGRlong                 tempdummy;
	IGRlong			status;
	struct IGRpolyline	polyline;	/* internal working structure*/
	struct IGRbsp_curve	*absg;
	IGRchar			*class_attr;
	IGRboolean		maret;		/* MA function return status */
extern    IGRboolean    MApytobc();
	struct GUcommon_header_info element;	/* GUgetname info	     */
 	IGRint			has_link;
	IGRchar			name[257];	/* element's name	     */
	IGRshort		set = 1;
	IGRshort		props;
	IGRchar			*typeface = NULL;
	IGRchar			*charmap = NULL;
#ifdef BIG_ENDIAN
	IGRshort		ndices;

	if ( me->IGDS_file_type == GU_2I )
		ndices = 4;
	else
		ndices = 6;
	GRswap_type3_ele(me->cvt_bufs.ele_buf,ndices);
#endif
	igdsline = (struct IGDS_line *) me->cvt_bufs.ele_buf;

	/*
 	 *  format buffer to hold B-spline representation
	 *  of object to translate
 	 */

	absg = (struct IGRbsp_curve *) me->cvt_bufs.bs_buf;
	absg->poles = (IGRdouble *) (GRalign_double(absg + 1));
	absg->knots = &(absg->poles[12]);

	/*
	 *  Set up internal working polyline.
	 */

	polyline.num_points = 2;
	polyline.points = absg->poles;

	if ( me->IGDS_file_type == GU_2I )
	{
	    /*
	     * 2-D line
	     */

	    total_coords = 4;

	    OM_BLOCK_MOVE(&(igdsline->pnts_ptr), points, 16 );

	    i = j = 0;
	
	    while ( i < total_coords )
	    {
		GUswapint ( &(points[i]), &tempdummy);
                polyline.points[j] = (IGRdouble) tempdummy;
		i++;
		j++;
		GUswapint ( &(points[i]), &tempdummy);
                polyline.points[j] = (IGRdouble) tempdummy;
		i++;
		j++;
		polyline.points[j++] = GUACT_Z_2D;
	    }
	}
	else
	{
	    /*
	     * 3-D line
	     */
	
	    total_coords = 6;

	    OM_BLOCK_MOVE( &(igdsline->pnts_ptr), points, 24 );

	    for ( i = 0; i < total_coords; i++ )
	    {
	   	GUswapint ( &(points[i]), &tempdummy);
                polyline.points[i] = (IGRdouble) tempdummy;
	    }
	}

	/*
	 *  convert internal polyline to internal B-spline representation
	 */

	maret = MApytobc ( msg, &polyline, me->cvt_bufs.bs_buf );

	if ( !(maret & 1) )
	{
	    /*
	     *  error converting igdsline 
	     */
	
	    return(OM_E_ABORT);
	}


	/*
	 *  Set the class of OSA line object as well as the 
	 *  variable length array descriptors.
	 */

	if ( (igdsline->header.properties & 0x8000 ) == 0x8000 )
	{

	    GRbclnextend(msg,absg,absg);

	    strcpy ( class_name, GUinfline_classes[me->object_type] );

	}
	else if ( (polyline.points[0] == polyline.points[3]) &&
		  (polyline.points[1] == polyline.points[4]) &&
		  (polyline.points[2] == polyline.points[5]) )
	{
	    strcpy ( class_name, GUpoint_classes[me->object_type] );
	}
	else
	{

	    strcpy ( class_name, GUlineseg_classes[me->object_type] );

	}

	class_attr = NULL;


	/*
	  Check the user data linkage for an element name.
	*/

	element = igdsline->header;
	has_link = GUattr_link (msg, &igdsline->header, name, 
			&igdsline->header.symbology, typeface, charmap);


	/*
	 *  construct an OSA object
	 */

	status = GUconstruct( me->cvt_bufs.bs_buf, object_info,
		    class_name, &igdsline->header.level,
		    &igdsline->header.symbology, &igdsline->header.properties,
		    class_attr, &me->scale_factor, &me->current_env );

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

	return (status);
}

end implementation COcvigdsige;
