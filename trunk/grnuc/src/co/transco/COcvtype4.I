/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function converts an IGDS line string to an OSA line 
 *  string.  If the line string is orthogonal, then an OSA
 *  orthogonal line string is created.  The new object will be
 *  added to the R-tree.
 */

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "OMmacros.h"
#include "gocmacros.h"

from GRgraphics import GRchgprops;

method cvt_type4 (IGRlong *msg; struct GRid *object_info)
{
	struct IGDS_linestring	*igdslnstr;

	static IGRchar		*GUlinestr_classes[3] = { "GR2ilinestr",
							  "GR3ilinestr",
							  "GR3dlinestr" };

	IGRchar		        class_name[80];	/* class name for object     */
	struct IGRbsp_curve	*absg;		/* pointer to absg geometry  */
	IGRshort		i,j;		/* loop counter		     */
	IGRshort		total_coords;	/* total coordinates in shape*/
	IGRlong			total_pts;
	IGRlong			points[303];
        IGRlong                 tempdummy;
	struct IGRpolyline	polyline;	/* internal working structure*/
	IGRchar			*class_attr;
	IGRlong 		status = FALSE;	
	IGRboolean		maret;		/* MA function return status */
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MApytobc();
extern    IGRboolean    MAidmx();
	struct GUcommon_header_info element;	/* GUgetname info	     */
	IGRint			has_link;
	IGRchar			name[257];	/* element's name	     */
	IGRshort		set = 1;
	IGRshort		props;
	IGRchar			*typeface = NULL;
	IGRchar			*charmap = NULL;
#ifdef BIG_ENDIAN
	IGRshort		ndices;
	IGRshort                direc=0;

        if ( me->IGDS_file_type == GU_2I )
	    ndices = 2;
        else
            ndices = 3;
        GRswap_type4_ele(me->cvt_bufs.ele_buf,ndices,direc);
#endif

igdslnstr = (struct IGDS_linestring *) me->cvt_bufs.ele_buf;

class_attr = NULL;

/*
 *  set up internal working polyline
 */

absg = (struct IGRbsp_curve *) me->cvt_bufs.bs_buf;

absg->poles = (IGRdouble *) (GRalign_double (absg + 1));
absg->knots = &(absg->poles[igdslnstr->lnstr.num_points * 3]);

polyline.num_points = igdslnstr->lnstr.num_points;
polyline.points = absg->poles;

/*
 *  Extract the coordinates of the line string.
 */
 
if ( me->IGDS_file_type == GU_2I )
{
    /*
     * 2-D shape
     */

    total_coords = polyline.num_points * 2;

    OM_BLOCK_MOVE( &(igdslnstr->lnstr.pnts_ptr), points, total_coords*4 );

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

    OM_BLOCK_MOVE( &(igdslnstr->lnstr.pnts_ptr), points, total_coords*4 );

    for ( i = 0; i < total_coords; i++ )
    {
	GUswapint ( &(points[i]), &tempdummy);
        absg->poles[i] = (IGRdouble) tempdummy;
    }
}

strcpy ( class_name, GUlinestr_classes[me->object_type] );

/*
    Check the user data linkage for any attribute linkage.
 */

element = igdslnstr->header;
has_link = GUattr_link (msg, &igdslnstr->header, name,
			&igdslnstr->header.symbology, typeface, charmap);

/*
 *  check for disconnects in line string
 */

i = 0;
total_pts = polyline.num_points;

while ( i < total_pts )
{

    if (( absg->poles[i * 3] == -2147483648.0 )
       && ( absg->poles[(i * 3) + 1] == -2147483648.0 ))
    {
	/*
	 *  Found disconnect in IGDS linestring, construct this
	 *  portion as an OSA linestring object, and continue to
	 *  process the remaining portion of the IGDS linestring
	 *  element.
	 */

	absg->num_poles = polyline.num_points = i;

	/*
	 *  convert internal polyline to internal B-spline representation
 	 */

	maret = MApytobc ( msg, &polyline, absg );

    	/*
     	 *  Construct OSA object.
     	 */


    	status = GUconstruct ( me->cvt_bufs.bs_buf, object_info,
		      class_name, &igdslnstr->header.level,
	              &igdslnstr->header.symbology, 
		      &igdslnstr->header.properties,
		      class_attr, &me->scale_factor, &me->current_env );


	absg->poles = polyline.points = &(absg->poles[(i+1)*3]);
	total_pts -= (i+1);
    	i = 0;

    }
    else
    {
	/*
	 *  No disconnect was found at this point, check
	 *  the next point of the linestring.
	 */

	++i;

    }
}


if ( total_pts > 0 )
{
    absg->num_poles = polyline.num_points = total_pts;

    /*
     *  convert internal polyline to internal B-spline representation
     */

    maret = MApytobc ( msg, &polyline, absg );


    /*
     *  Construct OSA object.
     */

    status = GUconstruct ( me->cvt_bufs.bs_buf, object_info, 
		  class_name, &igdslnstr->header.level,
	          &igdslnstr->header.symbology, 
		  &igdslnstr->header.properties,
		  class_attr, &me->scale_factor, &me->current_env );


} /* end if */


if (has_link & HAS_FILLED_TYPE)
{
    props = 0;
    props |= GRFILLED_DISPLAY;
    status = om$send (msg = message GRgraphics.GRchgprops (msg, &set, &props),
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
