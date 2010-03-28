/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GR2ptlsext
 
     Abstract: This routine takes two points that define a line
     	segment and a scale factor and finds two points along
     	the line at a distance from the input points. The distance
     	is computed as the original distance between the input
     	points times the scale factor. (Hence the scale factor
     	acts as a percentage of the orginal distance between the
     	points.)

-----
%SC%

     VALUE = GR2ptlsext(msg,pt1,pt2,sf,spt1,spt2)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     pt1	  IGRpoint	 first point of line segment
     pt2	  IGRpoint	 second point of line segment
     sf	 	  *IGRdouble	 scale factor (as a percentage of
     				 distance between pt1 and pt2)
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful

     spt1	  IGRpoint	 pt1 scaled by sf * dist(pt1,pt2)
     spt2	  IGRpoint	 pt2 scaled by sf * dist(pt1,pt2)


     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - successful
                        FALSE- not possible

-----
%MD%

     MODULES INVOKED:
		MAsubvc
		MAscalvc
		MAaddvc
		
-----
%NB%

     NOTES:
            The cooresponding input and output points may be the same.

-----

%CH%
     CHANGE HISTORY:
	
	RDH  05/06/88  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
Find the vector from point1 to point2. Scale this vector by the
input scale factor and add the scaled vector to point2 and subtract
it from point1 to get the output points one and two respectively.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"

IGRboolean GR2ptlsext(msg,pt1,pt2,sf,spt1,spt2)

	   IGRlong      *msg;			/* return code		     */
	   IGRpoint	pt1;			/* 1st point of segment	     */
	   IGRpoint	pt2;			/* 2nd point of segment	     */
	   IGRdouble    *sf;			/* scale factor		     */

{
  IGRvector v;
  
  MAsubvc(msg,pt2,pt1,v);
  MAscalvc(msg,sf,v,v);
  MAaddvc(msg,pt2,v,pt2);
  MAsubvc(msg,pt1,v,pt1);
  
  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
