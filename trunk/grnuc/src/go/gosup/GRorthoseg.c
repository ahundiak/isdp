/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRorthoseg
 
     Abstract: This routine takes two points defining a line segment and
	      a third point to be used to define a new line segment such
	      that the new segment is orthogonal to the first segment 
	      with its first point being the second point of the first
	      segment and its second point being at the minimum distance
	      from point three.


-----
%SC%

     VALUE = GRorthoseg(msg,point1,point2,point3,out_point)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     point1	  IGRpoint	 first point of line segment
     point2	  IGRpoint	 second point of line segment
     point3	  IGRpoint	 reference point 
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred
					MASDGENRAT - point1 and 
				 point2 were identical.

     out_point    IGRpoint	 point such that <point1,point2> is
				 orthogonal to <point2,out_point>
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - out_point found
                        FALSE- out_point not found

-----
%MD%

     MODULES INVOKED:
		     MAsubvc
		     MAunitvc
		     MAptplproj
-----
%NB%

     NOTES:
	    This routine does not make any assumptions about the
	   plane that out_point is found in. If this routine is
	   used repeatedly as in constructing a planar orthogonal
	   line string, point3 should already be in the construction
	   plane.
	    
	    Due to the above consideration, this routine may be used
	   to construct non-planar orthogonal line strings, shapes,
	   etc, etc.
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  03/13/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine uses the unitized vector point1 - point2 as the normal
vector of a plane with point2 as the point in the plane and simply
projects point3 onto this plane to find out_point.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"

extern    IGRboolean    MAsubvc();
extern    IGRboolean    MAunitvc();
extern    IGRboolean    MAptplproj();

IGRboolean GRorthoseg(msg,point1,point2,point3,out_point)

	   IGRlong  *msg;			/* return code		      */
	   IGRpoint  point1;			/* first point of line segment*/
	   IGRpoint  point2;			/* second point of line seg   */
	   IGRpoint  point3;			/* reference point            */
	   IGRpoint  out_point;			/* output point which makes   */
						/* a new orthogonal segment to*/
						/* the line segment   	      */

{
  struct IGRplane pl;				/* plane to project onto      */

  IGRvector normal_vc;				/* normal vector of pl        */

  IGRlong mess;					/* return code		      */



  *msg = MSSUCC;

  MAsubvc(&mess,point1,point2,normal_vc);	/* create plane normal vector */

  if( MAunitvc(msg,normal_vc,normal_vc) )	/* unitize plane normal vector*/
    {
      pl.normal = normal_vc;			/* init plane		      */
      pl.point  = point2;

      MAptplproj(msg,point3,&pl,out_point);	/* project point3 onto pl     */
    }
  
  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
