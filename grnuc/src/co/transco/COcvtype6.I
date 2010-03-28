/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function converts an IGDS shape to an OSA polygon.
 *  If the shape is a block, then an OSA orthogonal polygon
 *  is created.  The new object will be added to the R-tree.
 */

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "OMmacros.h"
#include "gocmacros.h"

from GRgraphics import GRchgprops;

method cvt_type6 (IGRlong *msg; struct GRid *object_info)
{
	struct IGDS_shape	*igdspolygon;

	static IGRchar		*GUorthpoly_classes[3] = { "GR2iorthpoly",
							   "GR3iorthpoly",
							   "GR3dorthpoly" };

	static IGRchar		*GUpoly_classes[3] = {	"GR2ipolygon",
							"GR3ipolygon",
							"GR3dpolygon" };

	IGRchar		   class_name[80];	/* class name for object     */
	struct IGRbsp_curve	*absg;		/* pointer to absg geometry  */
	IGRshort		i,j;		/* loop counter		     */
	IGRshort		total_coords;	/* total coordinates in shape*/
	IGRlong			points[303];
        IGRlong                 tempdummy;
	struct IGRpolyline	polyline;	/* internal working structure*/
	IGRvector		vector1;	/* internal vector	     */
	IGRvector		vector2;	/* internal vector	     */
	IGRdouble		dotprod;	/* internal dot product	     */
	IGRchar			*class_attr;
	IGRlong 		status;	
	IGRboolean		maret;		/* MA function return status */
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MApytobc();
extern    IGRboolean    MAidmx();
	struct GUcommon_header_info element;	/* GUgetname info	     */
	IGRint			has_link;
	IGRchar			name[257];	/* element's name	     */
	IGRshort 		set = 1;
	IGRshort		props;
	IGRchar			*typeface = NULL;
	IGRchar			*charmap = NULL;
#ifdef BIG_ENDIAN
	IGRshort		ndices;
	IGRshort		direc = 0;
	
        if ( me->IGDS_file_type == GU_2I )
           ndices = 2;
        else
           ndices = 3;
        GRswap_type6_ele(me->cvt_bufs.ele_buf,ndices,direc);
#endif

igdspolygon = (struct IGDS_shape *) me->cvt_bufs.ele_buf;

absg = (struct IGRbsp_curve *) me->cvt_bufs.bs_buf;

/*
 *  set up internal working polyline
 */

absg->poles = (IGRdouble *) (GRalign_double(absg + 1));
absg->knots = &(absg->poles[igdspolygon->shape.num_points * 3]);

polyline.num_points = igdspolygon->shape.num_points;
polyline.points = absg->poles;

if ( me->IGDS_file_type == GU_2I )
{
    /*
     * 2-D shape
     */

    total_coords = polyline.num_points * 2;

    OM_BLOCK_MOVE( &(igdspolygon->shape.pnts_ptr), points, 
		   total_coords*4 );

    i = j = 0;

    while ( i < total_coords )
    {
	GUswapint ( &(points[i]), &tempdummy);
        absg->poles[j] = (IGRdouble) tempdummy;
	i++;
	j++;
	GUswapint ( &(points[i]), &tempdummy);
        absg->poles[j] = (IGRdouble) tempdummy;
	i++;
	j++;
	absg->poles[j++] = GUACT_Z_2D;
    }
}
else
{
    /*
     * 3-D shape
     */

    total_coords = polyline.num_points * 3;

    OM_BLOCK_MOVE( &(igdspolygon->shape.pnts_ptr), points, 
		   total_coords*4 );

    for ( i = 0; i < total_coords; i++ )
    {
	GUswapint ( &(points[i]), &tempdummy);
        absg->poles[i] = (IGRdouble) tempdummy;
    }
}

/*
 *  convert internal polyline to internal B-spline representation
 */

maret = MApytobc ( msg, &polyline, absg );

if ( igdspolygon->shape.num_points == 5 )
{
    /*
     * check if shape is really a block
     */

    strcpy ( class_name, GUorthpoly_classes[me->object_type] );

    for ( i=0; i<=igdspolygon->shape.num_points - 3; ++i )
    {
	/*
         * form vectors from adjacent segments
	 *	vector1 = point(i+1) - point(i)
	 *	vector2 = point(i+1) - point(i+2)
  	 */

	for ( j=0; j<3; ++j )
	{
	    vector1[j] = absg->poles[(i*3)+j+3] - absg->poles[(i*3)+j];
	    vector2[j] = absg->poles[(i*3)+j+3] - absg->poles[(i*3)+j+6];
	}

	/*  
	 *  determine dot product using adjacent segments
	 *  if dot product = 0, then adjacent segments are orthogonal
	 */

	if ( MAdotvc(msg, vector1, vector2, &dotprod) )
	{
	    if ( dotprod != 0 )
	    {
		strcpy ( class_name, GUpoly_classes[me->object_type] );
	    }
	}
    }
}
else
{
    strcpy ( class_name, GUpoly_classes[me->object_type] );
}

class_attr = NULL;

/*
   Check the user data linkage for an element name.
*/

	element = igdspolygon->header;
	has_link = GUattr_link (msg, &igdspolygon->header, name,
				&igdspolygon->header.symbology, 
				typeface, charmap);

	
/*
 *  Construct OSA object.
 */

	status = GUconstruct ( me->cvt_bufs.bs_buf, object_info, 
	      class_name, &igdspolygon->header.level,
	      &igdspolygon->header.symbology, &igdspolygon->header.properties,
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

        if (has_link & HAS_IVEC_TYPE)
        {
            GRConnectToNodes(object_info);  /* mrm - added for I/FRATEL */
        }

return (status);

}

end implementation COcvigdsige;
