/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRcompranges - computes the ranges for a
		reference file object

Synopsis

        GRcompranges(msg,clip_poly,vw_volume,vw_origin,
		vw_rotation,ref_to_master,master_to_ref,
		ref_range,master_range)

	IGRlong 	*msg;		 return code			
	struct IGRpolygon *clip_poly;	 clipping polygon 		
	IGRdouble	*vw_volume;	 saved view volume		
	IGRdouble	*vw_origin;	 view origin			
	IGRmatrix	vw_rotation;	 view rotation matrix		
	IGRmatrix	ref_to_master;	 transformation reference file
					   to master file 		
	IGRmatrix	master_to_ref;	 transformation master file to
					   reference file		
	IGRdouble	*ref_range;	 range in reference file 
					   world coordinates		
	IGRdouble	*master_range;	 range in master file world	
					   coordinates			

Description
	This function is a special function to be used by the
	reference file methods.  It computes the ranges needed
	by the reference file object.  The ref_range is the 
	range used by the GRreffile object to initiate a 
	pass through the R-tree in the reference file space.

	The master_range is used by the GRreffile object to
	insert itself in the R-tree of the master file.  This 
	is to allow locate to operate on the objects in the
	file and on the attachment itself.

Diagnostics
	The possible return values for the msg argument are:
	
	MSSUCC - successful completion
	MSFAIL - error occurred.

Notes
	None.

History
	MAS 	04/03/87	Design Date

\*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "OMprimitives.h"
#include "msdef.h"

IGRint GRcompranges(msg,clip_poly,vw_volume,vw_origin,
	vw_rotation,ref_to_master,master_to_ref,
	ref_range,master_range)

IGRlong 	*msg;		/* return code			*/
struct IGRpolygon *clip_poly;	/* clipping polygon 		*/
IGRdouble	*vw_volume;	/* saved view volume		*/
IGRdouble	*vw_origin;	/* view origin			*/
IGRmatrix	vw_rotation;	/* view rotation matrix		*/
IGRmatrix	ref_to_master;	/* transformation reference file
				   to master file 		*/
IGRmatrix	master_to_ref;	/* transformation master file to
				   reference file		*/
IGRdouble	*ref_range;	/* range in reference file 
				   world coordinates		*/
IGRdouble	*master_range;	/* range in master file world	
				   coordinates			*/

{
    IGRlong msg1;		/* return value			*/

    IGRint i;			/* loop index			*/

    IGRdouble points[30],	/* polyline points		*/
    	      points2[150];

    struct IGRpolyline py,	/* polylines			*/
	transformed_clip_poly;

    struct IGRlbsys lbsys;	/* local bounded system		*/
    IGRdouble 	test_range1[6],	/* temporary ranges		*/
		test_range2[6];	


    *msg = MSSUCC;		/* initialize return variables	*/

    for (i=0; i<3; ++i)		/* load local bounded system	*/
    {
	lbsys.diag_pt1[i] = vw_volume[i];
	lbsys.diag_pt2[i] = vw_volume[i+3];
    }
    MAlswcmx(&msg1,vw_origin,vw_rotation,lbsys.matrix);
    py.points = points;	 	/* assign pointer			*/
				/* polyine is in ref. file world coord.	*/
    MApyfrlb(msg,&lbsys,&py);    
    /* 
     * This local bounded system takes you from reference file
     * local coordinates to reference file world coordinates.
     * The polyline formed above is in reference file world coordinates.
     * The input clip_poly is in master file world coordinates.
     * It must be transformed to reference file world coordinates
     * to get its range in terms of the reference file's system.
     */
    if (clip_poly)		
    {
	if (clip_poly->num_points > 50)
	{
	    transformed_clip_poly.points = (IGRdouble *)om$malloc(
		size = (sizeof(IGRdouble) * clip_poly->num_points * 3) );

	    if (!transformed_clip_poly.points)
	    {
	    	*msg = MSFAIL;
		goto wrapup;
	    }
	}
	else
	{
	    transformed_clip_poly.points = points2;
	}
				/* transform points to ref.coord.	*/
	MAptsxform(msg,&clip_poly->num_points,master_to_ref,
		clip_poly->points,transformed_clip_poly.points);

	transformed_clip_poly.num_points = clip_poly->num_points;
        if (1 & *msg)
        {
	    MApyextents(msg,&transformed_clip_poly,test_range1,
		&test_range1[3]);
    	    MApyextents(msg,&py,test_range2,&test_range2[3]);
	
	    for (i=0; i<3; ++i)
	    {
	        ref_range[i] = ((test_range1[i] < test_range2[i]) ?
			     test_range1[i] : test_range2[i]);
	        ref_range[i+3] = ((test_range1[i+3] < test_range2[i+3]) ?
			     test_range2[i+3] : test_range1[i+3]);

	    }
	}
    }
    else
    {
	MApyextents(msg,&py,ref_range,&ref_range[3]);
    }
    if (1 & *msg)
    {
	/* the Polyline defining the extents in terms of the refernce
	 * file coordinates must now be transformed to the master
	 * master file world system.
	 */

				/* transform points to ref.coord.	*/
	MAptsxform(msg,&py.num_points,ref_to_master,
		py.points,py.points);

	if (1 & *msg)
	{			/* get extents in master file coord	*/
	    if (clip_poly)
	    {
 	        MApyextents(msg,clip_poly,test_range1,&test_range1[3]);
    	        MApyextents(msg,&py,test_range2,&test_range2[3]);
	
	    	for (i=0; i<3; ++i)
	    	{
	            master_range[i] = ((test_range1[i] < test_range2[i]) ?
		   	test_range1[i] : test_range2[i]);
	    	    master_range[i+3] = 
		    	((test_range1[i+3] < test_range2[i+3]) ?
		      	  test_range2[i+3] : test_range1[i+3]);
		}
	    }
	    else
	    {
		MApyextents(msg,&py,master_range,&master_range[3]);
	    }
	}
    }

    if (clip_poly)
    {
	if (clip_poly->num_points > 50)
	{
	    om$dealloc(ptr = transformed_clip_poly.points);
	}
    }

  wrapup:

    return(1 & *msg);
}
