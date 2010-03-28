/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GR3dlineseg
     METHOD NAME:  GRgetpolyline

     Abstract: 
		This method retrieves the polyline representation
	of the object.
		The input matrix may be passed to the object 
	representing a transformation to be applied to the object
	before placing it in the buffer.

-----
%SC%    

    VALUE =  GRgetpolyline(msg,matrix_type,matrix,action,polyline)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort       type of transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *action	   IGRint	  action desired
				    0 - return number of points
				    1 - return polyline ( memory
					must already be allocated)
				    2 - buffer sent in. Size of the
				   	buffer is set in polyline
				        number of points
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
				      due to allocation problems
				    - MSINARG - buffer sent in not large
					enough, polyline->num_points
					reset to appropriate size.

     *polyline	 struct IGRpolyline
				 polyline structure
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

	MAS 	10/06/87: Design Date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method returns a polyline representation of an object.
	The the line segment is transformed to world coordinates 
	using the input transformation matrix.
----*/
/*EH*/

class implementation GR3dlineseg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "madef.h"
#include "gocmacros.h"
#include "OMmacros.h"

extern    IGRboolean    GRgentransutil();

method GRgetpolyline(IGRlong *msg; IGRshort *matrix_type;
	 IGRmatrix matrix; IGRint *action; struct IGRpolyline *polyline)
{

	IGRshort   flag;

	IGRlong	   OMmsg;		/* OM return status		*/

	IGRint     i;			/* loop index			*/


	*msg = MSSUCC;			/* initialize to success	*/
	OMmsg = OM_S_SUCCESS;

 	if (*action == 0)
	{
	     polyline->num_points = 2;
	}
	else
	{
	    if ( *action == 2)
	    {
	    	if (polyline->num_points < 2)
	    	{
		    polyline->num_points = 2;
		    OMmsg = OM_W_ABORT;
		    *msg = MSINARG;
		    goto wrapup;
	    	}
	    }
	    polyline->num_points = 2;

	    if (*matrix_type  != MAIDMX)
	    {
				/* transform points			*/
	 	if (!GRgentransutil(msg,matrix_type,matrix,
			&polyline->num_points,me->points,
			polyline->points,&flag))
		{			
		    *msg = MSFAIL;
		    OMmsg = OM_E_ABORT;
		}

	    }
	    else
	    {
		for ( i=0; i<6; ++i)
		{
		    polyline->points[i] = me->points[i];
		}
	    }
	}

wrapup:

	

	return (OMmsg);
}

end implementation GR3dlineseg;
