/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GOfillet
 
     Abstract: This routine serves as an interface to the math routine 
	      which finds a fillet arc between two curves.

-----
%SC%

     VALUE = GOfillet(msg,bc1,bc2,tanpt1,tanpt2,radius,center,view,bsp_arc)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc1	  IGRbsp_curve	 B-spline curve arc is tangent to
     bc2	  IGRbsp_curve	 B-spline curve arc is tangent to
     tanpt1	  IGRpoint	 approximate tangent point on bc1
     tanpt2	  IGRpoint	 approximate tangent point on bc2
     radius	  IGRdouble	 radius of desired tangent arc
     center	  IGRpoint	 approximate center of desired arc
     view	  IGRvector	 counter-clockwise indicator
          
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure of math 
				 algorithm to find solution

     bsp_arc	  IGRbsp_curve	 arc tangent to bc1 and bc2
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - tangent arc found
                        FALSE- tangent arc not found


-----
%MD%

     MODULES INVOKED:
		BSfillet

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
 This routine serves as an interface to the BSfillet math routine.
It will deallocate the curve which the BSfillet routine allocates
after copying it to the output curve.

----*/
/*EH*/


#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "bserr.h"

IGRboolean GOfillet(msg,bc1,bc2,tanpt1,tanpt2,radius,center,view,bsp_arc)

	   IGRlong	       *msg;		/* return code		     */
	   struct IGRbsp_curve *bc1;		/* B-spline curve	     */
	   struct IGRbsp_curve *bc2;		/* B-spline curve	     */
	   IGRpoint		tanpt1;		/* approx tangent pt on bc1  */
	   IGRpoint		tanpt2;		/* approx tangent pt on bc2  */
	   IGRdouble	       *radius;		/* radius of desired arc     */
	   IGRpoint		center;		/* approximate center of arc */
	   IGRvector		view;		/* counter-clockwise indicator*/
	   struct IGRbsp_curve *bsp_arc;	/* desired tangent arc       */

{
  IGRpoint  cent;				/* center of fillet	     */
  IGRpoint  p0,p1;				/* tangent points	     */
  
  IGRdouble fpar[2];				/* parameters of tangent pts */
  IGRdouble h;
  

  IGRint bs_rc;					/* return code		     */

  
  IGRshort option = 0;
  
  *msg = MSSUCC;

  BSfillet(&bs_rc,bc1,bc2,tanpt1,tanpt2,center,radius,bsp_arc,cent,fpar);

  if( bs_rc == BSSUCC )
  {
    MAbcueval(msg,bc1,&option,&fpar[0],p0,&h);
    MAbcueval(msg,bc2,&option,&fpar[1],p1,&h);
    
    GRarc2ptr(msg,cent,p0,p1,radius,view,bsp_arc);
  }
  else
  {
    *msg = MSFAIL;
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
