/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GRptseqspace

     Abstract: 	This module produces a specified number of
		equally spaced points on an object.  The 
		points begin at point1 and end at point3.

		Point2 is used to determine direction on
		closed curves.
-----
%SC%    

	GRptseqspace(msg,mx_type,matrix,point1,point2,point3,
		     p1,p2,p3,dist,num,out_points)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
	*mx_type  IGRshort	 matrix type
	matrix    IGRmatrix	 environment matrix	
	point1	  IGRpoint	 beginning point for equal spaced
				    points
	point2    IGRpoint	 direction point needed for closed
				    objects
	point3    IGRpoint	 ending point for equal spaced points
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2
	*p3	  GRparms	 structure for parameter information
				    for point3
   	*num	  IGRlong	 number of points requested

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
	*msg	  IGRlong	 completion code
				    MSSUCC - successful completion
				    MSFAIL - error occured
	*out_points IGRdouble	 output points 

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	GRpybcueqspace

     Methods:
	
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	If your object is an open curve, point2 (and its 
	parameter,p2) and point3 (with parameter, p3) 
	may be the same. 

	The input points, point1 and point3 will be included
	in the out_points array as the first and last
	points respectively.

-----
%CH%

     CHANGE HISTORY:
	
	MAS     05/15/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method produces the requested number of equally spaced points
on a curve. 

To do this a math routine is called which produces the points.
	
----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    GRpybcueqspace();

method GRptseqspace(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
		 IGRpoint point1,point2,point3;struct GRparms *p1,
		 *p2,*p3; IGRlong *num;IGRdouble *out_points)

{

    IGRlong	OMmsg;			/* OM return value		*/
    IGRlong     msg2;			/* local return code		*/

    struct  IGRpolyline py;		/* polyline for math routine	*/

    IGRchar	*ptr;			/* pointer to cache 		*/

    *msg = MSSUCC;			/* initialize return codes	*/
    OMmsg = OM_S_SUCCESS;

 					/* get abstract geometry	*/
    GRgetabsg(&msg2,mx_type,matrix,&ptr,i);

    if (1 & msg2)			/* see if successful		*/
    {				
        py.points = out_points;
					/* produce the desired point	*/
	if ( ! GRpybcueqspace(&msg2,ptr,num,point1,point3,point2,
			     &p1->u,&p3->u,&p2->u,&py))
	{
	    *msg = MSFAIL;		/* math routine failed		*/
	    OMmsg = OM_E_ABORT;
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

