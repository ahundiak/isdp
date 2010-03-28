/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GRptalong

     Abstract: 	This module produces a point on an object at a
		given distance from an input point in the 
		direction of a second input point.
	
-----
%SC%    

	GRptalong(msg,mx_type,matrix,point1,point2,p1,p2,dist,
		  out_point)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
	*mx_type  IGRshort	 matrix type
	matrix    IGRmatrix	 environment matrix	
	point1	  IGRpoint	 beginning point for distance measure
	point2    IGRpoint	 direction point
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2
   	*dist	  IGRdouble	 distance from point1 to produce new
				    point

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  IGRlong	 completion code
				    MSSUCC - successful completion
				    MSFAIL - error occured
	out_point IGRpoint	 output point

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	BSptsdlcv
	BSprptoncv
	BScveval
	BSmkvec
	BSnorvec

     Methods:
	
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	If a curve is a closed curve, the results produced by
	this method may not be what you expect.  The results
	are, however, correct.

	This method will not produce a point off the endpoint
	of the curve.  An error will be returned if this is
	requested.

-----
%CH%

     CHANGE HISTORY:
	
	MAS     05/14/86 : Design date.
	BJ	06/15/90 : Modified to work correctly when the start point
			   and the direction point are same.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method produces a point on a curve at a specified distance
from an input point.  A second point is used to determine the 
direction from the input point.  This method sets a direction
indicator to indicate if the point to be produced is in a 
negative direction (i.e., towards the beginning point of the 
curve) or positive direction (i.e., towards the ending point
of the curve).  A math routine is then called to produce the
desired point.
	
----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern IGRboolean BSprptoncv();
extern IGRboolean BSptsdlcv();

method GRptalong(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
		 IGRpoint point1,point2;struct GRparms *p1,*p2;
		 IGRdouble *dist;IGRpoint out_point)
{
	
    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/
    IGRlong	size;

    IGRchar	*ptr;			/* pointer to cache 		*/

    IGRboolean	on_curve;	

    IGRdouble	buffer[1000],
		u; 

    *msg = MSSUCC;			/* initialize to failure	*/
    OMmsg = OM_S_SUCCESS;

    OMmsg = om$send (msg = message GRvg.GRgetexsize
	    (msg,mx_type,matrix,&size),
	targetid = my_id);

    if ( 1 & OMmsg)
    {
	if (size > sizeof(buffer))
	{
	    ptr = om$malloc(size = size);
	    if (!ptr)
	    {
		OMmsg = OM_E_ABORT;
		*msg = MSFAIL;
	    }
	}
	else
	{
	    ptr = (IGRchar *)buffer;
	}
	
	OMmsg = om$send(msg = message GRvg.GRgetexgeom
	        (msg,mx_type,matrix,ptr),
	    targetid = my_id);

	if ( 1 & OMmsg)
	{
				/* get the u parameter for base point 	*/
	    if (BSprptoncv(&msg2,ptr,point1,&u,&on_curve))
	    {
		IGRdouble dummy_u;
		
				/* get the u parameter for direction point */
	    	BSprptoncv(&msg2,ptr,point2,&dummy_u,&on_curve);
 
		               /* check if u and dummy_u are  zeroes*/
		if( (u < 0.000005) && (dummy_u < 0.000005) ) 
		{	
			/* change point2 to fool BSptsdlcv */

			IGRdouble  dummy[3];

			dummy_u += 0.01;
				/* get new point2 */
			BScveval(ptr, dummy_u, 0, point2, &msg2);

			BSmkvec(&msg2, dummy, point2, point1);

			BSnorvec(&msg2, dummy);

			point2[0] = point1[0] + 2*dummy[0];
			point2[1] = point1[1] + 2*dummy[1];
			point2[2] = point1[2] + 2*dummy[2];
		}

		 			/* produce the desired point	*/
		if (!BSptsdlcv(&msg2,ptr,&u,point2,dist,out_point))
		{
	    	    *msg = MSFAIL;
	    	    OMmsg = OM_E_ABORT;
		}

	    }
	    else
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	    }
	}
    }    
    else
    {
	*msg = MSFAIL;			/* get abstract geometry failed	*/
	OMmsg = OM_E_ABORT;
    }

    return( OMmsg );

}
end implementation GRbspline;

