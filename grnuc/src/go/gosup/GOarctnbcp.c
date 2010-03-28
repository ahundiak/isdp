/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GOarctnbcpt
 
     Abstract: This routine finds an arc with a given center and end point
	      which is tangent to a B-spline curve given a start point 
	      which is an approximate point of tangency. The arc found
	      will be oriented counter-clockwise with respect to an
	      input vector.
-----
%SC%

     VALUE = GOarctnbcpt(msg,center,bc,tanpt,endpt,view,bsp_arc)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     center	  IGRpoint	 center of desired arc
     bc	 	  IGRbsp_curve	 curve arc is tangent to
     endpt	  IGRpoint	 end point of arc
     view	  IGRvector	 viewing vector
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure to find arc  
					MSINARG - invalid input, 
				 points are not distinct

     bsp_arc	  IGRbsp_curve	 desired arc
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - arc found
                        FALSE- no arc found

-----
%MD%

     MODULES INVOKED:
		     MAcrossvc
		     MAdotvc
		     BSactncvept
-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  07/16/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine forms two vectors from the input points and finds the
dot product of their cross product with the viewing vector to set
a flag for the math routine called which attempts to find the
desired arc.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "msdef.h"
#include "bserr.h"

IGRboolean GOarctnbcpt(msg,center,bc,tanpt,endpt,view,bsp_arc)

	   IGRlong             *msg;		/* return code		     */
	   IGRpoint		center;		/* center of desired arc     */
	   struct IGRbsp_curve *bc;		/* curve arc is tangent to   */
	   IGRpoint		tanpt;		/* approximate tangent point */
	   IGRpoint		endpt;		/* point used to find end    */
	   IGRvector		view;		/* vector used to find ccw   */
	   struct IGRbsp_curve *bsp_arc;	/* tangent arc		     */

{
  IGRint flag;					/* flag for desired arc	     */

  IGRlong mess;					/* return code		     */

  flag = 0;
  
  BSactncvept(flag,tanpt,center,endpt,view,bc,bsp_arc,&mess);

  if( mess != BSSUCC )
  {
    *msg = MSFAIL;
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
