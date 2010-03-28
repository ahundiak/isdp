/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dinfline
     METHOD NAME:  GRgetpolyline

     Abstract: 
		This method generates the abstract data
	representation for a 3-D double precision floating
	point infinite line and places the data in the
	standard buffer.  The input matrix may be passed
	to the object representing a transformation to be
	applied to the object before placing it in the buffer.

-----
%SC%    

     GRgetpolyline(msg,matrix_type,matrix,action,polyline)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort       type of transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *action	   IGRint	  action to be taken
				    0 - get number of points only
				    1 - return polyline
				    2 - default buffer sent in of size
					equal number of points
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
				      due to allocation problems
				    - MSINARG buffer not large enough;
				      polyline->num_points reset to 
				      the appropriate number needed

     *polyline	  struct IGRpolyline
				 pointer to geometry
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:  none.
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     10/06/87: Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method retrieves  the 3-D double precision floating
	point infinite line object in its polyline format.

	Then the object is transformed to world coordinates using the
	input transformation matrix.
----*/
/*EH*/

class implementation GR3dinfline;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "mapriv.h"
#include "gocmacros.h"

extern    IGRboolean    MAoptsxform();
extern    IGRboolean    MAlncbclip();

method GRgetpolyline(IGRlong *msg; IGRshort *matrix_type;
	 IGRmatrix matrix; IGRint *action; struct IGRpolyline *polyline)
{
	IGRboolean status;		/* generic function return	*/
	IGRlong    msg2;		/* working completion code	*/
	IGRlong	   OMmsg;		/* OM return status		*/
	IGRint	   i;			/* loop counter			*/

	struct     IGRline org_line;
	struct 	   IGRline ext_line;
	IGRpoint   pt1,pt2;


	*msg = MSSUCC;			/* initialize to success	*/
	OMmsg = OM_S_SUCCESS;

	if (*action == 0)
	{
	    polyline->num_points = 4;
	}
	else
	{
	    
	    if (*action == 2)
	    {
		if (polyline->num_points < 4)
	    	{
		    polyline->num_points = 4;
		    OMmsg = OM_W_ABORT;
		    *msg = MSINARG;
		    goto wrapup;
	    	}
	    }
	    for ( i = 0; i < 6; ++i )	/* load instance data into	*/
	    {				/* internal working array	*/
	        polyline->points[i+3] = me->points[i];
	    }

	    if (*matrix_type != MAIDMX)
	    {
	  	i = 2;

	  	status = MAoptsxform(&msg2,&i,matrix_type,matrix,
			&polyline->points[3],&polyline->points[3]);

	  	if (! status)		/* an error occurred		*/
	  	{
	    	    *msg = MSFAIL;	/* set error message		*/
	    	    OMmsg = OM_E_ABORT;
	    	    goto wrapup;
	  	}
	    }

/*
 *  Extrapolate the points defining the line to the edge of
 *  the design cube
 */
	    if ( me->inf_end != 3)
	    {
	        org_line.point1 = &polyline->points[3];
	        org_line.point2 = &polyline->points[6];

                pt1[0] = pt1[1] = pt1[2] = GRDGNLIMITS_MIN_D+1;
	        pt2[0] = pt2[1] = pt2[2] = GRDGNLIMITS_MAX_D-1;

	    	ext_line.point1 = polyline->points;
	    	ext_line.point2 = &polyline->points[9];

	    	status = MAlncbclip(&msg2,&org_line,pt1,pt2,&ext_line);
	
	    	if ( ! status )
	    	{
	            *msg = MSFAIL;
	    	    OMmsg = OM_E_ABORT;
	    	    goto wrapup;
	    	}
	    }
/*
 *  Check which end(s) of the line
 *  is considered infinite and adjust points
 *
 *  format the polyline in the following order:
 *
 *  1)  if inf_end = 0 (both ends considered infinite)
 *		pt1 = ext_line.point1
 *		pt2 = org_line.point1
 *		pt3 = org_line.point2
 *		pt4 = ext_line.point2
 *
 *  2)  if inf_end = 1 (end defined by 1st point considered infinite)
 *		pt1 = ext_line.point1
 *		pt2 = org_line.point1
 *		pt3 = org_line.point2
 *		pt4 = org_line.point2
 *
 *  3)  if inf_end = 2 (end defined by 2nd point considered infinite)
 *		pt1 = org_line.point1
 * 		pt2 = org_line.point1
 *		pt3 = org_line.point2
 *		pt4 = ext_line.point2
 *
 *  4) if inf_end == 3 (neither end is considered infinite)
 *
 * 	
 */

	    if ( me->inf_end == 1 )
	    {
	    	MAcopy(&polyline->points[9],org_line.point2,1,i);
	    }
	    else if ( me->inf_end == 2 )
	    {
	      	MAcopy(polyline->points,org_line.point1,1,i);
	    }
	    else if ( me->inf_end == 3)
	    {
		for (i=0; i<3; ++i)
		{
		    polyline->points[9+i] = polyline->points[6+i];
		    polyline->points[i] = polyline->points[3+i];
		}
	    }

	    polyline->num_points = 4;
	}

	

wrapup:
	return (OMmsg);
}

end implementation GR3dinfline;
