/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRbrlnconstr
 
     Abstract: This routine constructs a boreline from a point and
	      a view matrix representing the world-to-view matrix.

-----
%SC%

     VALUE = GRbrlnconstr(msg,point,view,boreline)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     point	  IGRpoint	 point on boreline
     view	  IGRmatrix	 view matrix (world to view)

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful

     boreline	  IGRline	 boreline

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - boreline constructed
                        FALSE- 

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:
            The input view matrix must be a world-to-view matrix.

-----

%CH%
     CHANGE HISTORY:
	
	RDH  01/04/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine assigns the input point to the first point of the line
and adds the view vector to the first point to find the second point
of the line. (The view vector is the third row of the matrix).

----*/
/*EH*/


#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"


IGRboolean GRbrlnconstr(msg,point,view,boreline)

	   IGRlong        *msg;			/* return code		      */
	   IGRpoint       point;		/* first point of line	      */
	   IGRmatrix      view;			/* view matrix		      */
	   struct IGRline *boreline;		/* constructed boreline	      */

{

  *msg = MSSUCC;

  boreline->point1[0] = point[0];		/* copy point to line point1  */
  boreline->point1[1] = point[1];
  boreline->point1[2] = point[2];

  boreline->point2[0] = point[0] + view[8];	/* add view vector to point to*/
  boreline->point2[1] = point[1] + view[9];	/* find point2 of boreline    */
  boreline->point2[2] = point[2] + view[10];

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
