/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	MAcpextents
 
     Abstract:	

		This function determines the extents of a
	curve prism geometry.  The extents are expressed
	in terms of the world coordinate system.

-----
%SC%

     VALUE = MAcpextents(message,cv_prism,low_point,high_point)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     cv_prism	  IGRcv_prism	 curve prism geometry structure

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong	 completion code
				    - MSSUCC if successful
				    - MADGENRAT (error) if an
					error occurred while
					transforming the points of
					the curve prism from local
					to world coordinates
				    - MSFAIL (severe) if an error 
					occurred
     low_point	  IGRpoint	 low extent point
     high_point   IGRpoint	 high extent point

     VALUE (IGRboolean) = TRUE	    - if successful	
		          FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:	

			MAptsxform
			MApyextents

-----
%NB%

     NOTES:		None.

-----

%CH%
     CHANGE HISTORY:
	
	MAS  05/27/87  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

	The bottom face of the curve prism will be broken into 
	a series of polylines each of size less than or equal to 
	MAX_SIZE (where MAX_SIZE is a locally defined constant).  
	These polylines will then be transformed to world coordi-
	nates (by function MAptsxform) and the extents will be 
	determined by MApyextents.  As each polyline is processed, 
	the overall extents will be accumulated.  If the height 
	is greater than zero, the top face of the curve prism is 
	processed in a similar manner.

	The constant MAX_SIZE is used to declare a local array to 
	avoid the problems associated with indeterminate length
	polygons (i.e., having to allocate a dynamic buffer) and to
	avoid the inefficiencies related to transforming one point 
	at a time (i.e., multiple function call overhead).
	
----*/
/*EH*/

#define MAX_SIZE 100

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ma.h"
#include "msdef.h"

extern    IGRboolean    MArptsxform();
extern    IGRboolean    MApyextents();

IGRboolean MAcpextents(message,cv_prism,low_point,high_point)

IGRlong	*message;		/* completion code		*/
struct IGRcv_prism *cv_prism;	
IGRpoint low_point;		/* low extent point		*/
IGRpoint high_point;		/* high extent point		*/

{
    IGRdouble prism_pts[(MAX_SIZE + 2) * 3]; 
    struct	IGRpolyline	prism_py;
    IGRlong			i,j,k,index;
    IGRboolean		value;

    /*
     *  initialize internal variables
     */
    
    i = j = 0;

    prism_py.points = prism_pts;
    
    /*
     *  Transform the points of the bottom face polygon
     *  and determine the extents of the coordinates 
     *  from the transformed points
     */

    while ( i < cv_prism->curve.num_poles )
    {
	i += MAX_SIZE;
	if ( i >= cv_prism->curve.num_poles )
	{
	    prism_py.num_points = (cv_prism->curve.num_poles 
				      - (i - MAX_SIZE));
	}
	else
	{
	    prism_py.num_points = MAX_SIZE;
	}
	
	/*
	 *  transform a section of the bottom face at a time
 	 */

	if ( value = MArptsxform(message,&prism_py.num_points,
				&cv_prism->curve.rational,
				&cv_prism->curve.weights[j],
				cv_prism->matrix,
				&cv_prism->curve.poles[j * 3],
				&prism_py.points[6]))
	{

	    /* 
	     *  load the first two points into the polyline
	     *
	     *  In the case of the first call to MApyextents
	     *  points 1 and 2 are the same as point 3, the 
	     *  extents are then determined from this set of
	     *  points
    	     *
	     *  In the case of a successive call to MApyextents
	     *  the low extent and high extent are moved into
	     *  point 1 and 2 respectively and point 3 begins
	     *  the set of new points
	     *	
	     *  This method allows MApyextents to always 
	     *  detemine the low and high extents from the
	     *  entire set of points requardless of which
	     *  group of points is being processed
	     */

	    prism_py.num_points += 2;		/*  adjust # of points to
						 *  include low and high
						 *  point from previous calls
						 */

	    if ( j == 0 )
	    {

		/*  
		 *  first call to MApyextents, low and high 
		 *  points have not been determined, so make 
		 *  two extra copies of point 1
		 */

		prism_py.points[0] = prism_py.points[6];
		prism_py.points[1] = prism_py.points[7];
		prism_py.points[2] = prism_py.points[8];

		prism_py.points[3] = prism_py.points[6];
		prism_py.points[4] = prism_py.points[7];
		prism_py.points[5] = prism_py.points[8];
	    }
	    else
	    {

		/*
		 *  successive call to MApyextents, use
		 *  low and high point from previous
	 	 *  call as point 1 and 2 in current call
		 */

		prism_py.points[0] = low_point[0];
		prism_py.points[1] = low_point[1];
		prism_py.points[2] = low_point[2];

		prism_py.points[3] = high_point[0];	
		prism_py.points[4] = high_point[1];	
		prism_py.points[5] = high_point[2];	
	    }

	    /*
	     *  determine the extents of this section
	     */

	    MApyextents(message,&prism_py,low_point,high_point);
	    j = i;
        }
	else
	{
	    *message = MADGENRAT;
	    goto wrapup;
	}
    }    
    if ( cv_prism->height != 0.0 )
    {
        i = 0;
	j = 0;
	    
    	while ( i < cv_prism->curve.num_poles )
        {
	    i += MAX_SIZE;
	    if ( i >= cv_prism->curve.num_poles )
	    {
	        prism_py.num_points = (cv_prism->curve.num_poles 
					  - (i - MAX_SIZE));
	    }
	    else
	    {
	        prism_py.num_points = MAX_SIZE;
	    }
	
            /*  add the height to the points of the bottom
	     *  face to create the top face of the cv_prism
	     */

	    index = j;		
	    for ( k = 0; k < prism_py.num_points * 3; k += 3)
	    {
	        prism_py.points[k+6] = cv_prism->curve.poles[(j*3)+k];
	    	prism_py.points[k+7] = cv_prism->curve.poles[(j*3)+k+1];
		if (cv_prism->curve.rational)
		{
	   	    prism_py.points[k+8] = 
			cv_prism->curve.poles[(j*3)+k+2] + 
			cv_prism->height * 
			cv_prism->curve.weights[index++];
		}
		else
		{
	   	    prism_py.points[k+8] = 
			cv_prism->curve.poles[(j*3)+k+2] + 
			cv_prism->height;
		}		
	    }
	    
	    /*
	     *  transform a section of the top face at a time
 	     */

	    if ( value = MArptsxform(message,&prism_py.num_points,
				 &cv_prism->curve.rational,
				 &cv_prism->curve.weights[j],
			    	 cv_prism->matrix,&prism_py.points[6],
				 &prism_py.points[6]))
	    {    
		prism_py.num_points += 2;

		prism_py.points[0] = low_point[0];
		prism_py.points[1] = low_point[1];
		prism_py.points[2] = low_point[2];

		prism_py.points[3] = high_point[0];	
		prism_py.points[4] = high_point[1];	
		prism_py.points[5] = high_point[2];	

	        /*
	         *  determine the extents of this section
	         */

	        MApyextents(message,&prism_py,low_point,high_point);
	        j = i;
            }
	    else
	    {
                *message = MADGENRAT;
	        goto wrapup;
	    }
        }
    }
     wrapup:
	    return(value);
}
