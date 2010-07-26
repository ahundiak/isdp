/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GOcttobc
 
     Abstract: This routine finds a circle tangent to a B-spline
	      at a point on the curve given an approximate tangent
	      point on the curve and the center of the circle.

-----
%SC%

     VALUE = GOcttobc(msg,bc,center_diam,tent_pt,cent_diam_flag,sol_u,bc_circle)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc		  IGRbsp_curve   B-spline curve
     center_diam  IGRpoint	 center/diameter pt of desired circle
     tent_pt	  IGRpoint  	 approximate tangent point
     center_diam_flag IGRint     flag for center ,0, or diameter ,1
                                 point input
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure of math
				 algorithm

     sol_u	  IGRdouble	 u par of tangent point
     bc_circle	  IGRbsp_curve	 B-spline circle tangent to bc
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - tangent circle found
                        FALSE- circle not found

-----
%MD%

     MODULES INVOKED:
                BSnorcvpt
                BSprptoncv
		MAsubvc
	        MAuvctnbc
		MAcrossvc
		MAcrrcnconst

-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  12/9/86  : Creation date.
	RDH  07/07/89 : Call BSnorcvpt and BSprptoncv
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine calls a math routine to find the line perpendicular to
the curve given the u par of the approximate tangent point. If it 
succeeds, the second point of the line is the point of tangency of 
the circle and curve. The length of the line is the radius of the 
circle. The direction vector of the line and the tangent vector of 
the curve at the tangent point are used to form the rotation matrix 
of the circle.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "maerr.h"
#include "msdef.h"
#include "bserr.h"

IGRboolean GOcttobc(msg,bc,center_diam,tent_pt,center_diam_flag,sol_u,bc_circle)

	   IGRlong               *msg;		/* return code		     */
	   struct IGRbsp_curve   *bc;		/* B-spline curve	     */
	   IGRpoint		  center_diam;	/* center of desired circle  */
	   IGRpoint		 tent_pt;	/* approx tan pt             */
	   IGRint                *center_diam_flag;/* center vs diam pt flag */
	   IGRdouble		 *sol_u;	/* u par of tan pt	     */
	   struct IGRbsp_curve   *bc_circle;	/* tangent circle	     */

{
  struct IGRbsp_curve ln;			/* perpendicular line	     */

  IGRpoint bcpt;				/* tangent point	     */

  IGRvector ln_vc;				/* direction vector of line  */
  IGRvector t;					/* tangent vector	     */
  IGRvector z;					/* normal vector to circle   */

  IGRdouble poles[6];				/* poles for ln		     */
  IGRdouble knots[4];				/* knots for ln		     */
  IGRdouble rad;				/* radius of tangent circle  */

  IGRlong mess;					/* return code		     */
  
  IGRboolean on_cv;
  extern IGRboolean BSnorcvpt();
  
 
  *msg = MSSUCC;

  ln.poles = poles;
  ln.knots = knots;

  BSnorcvpt(&mess,bc,center_diam,tent_pt,&ln);
  
  if( mess == BSSUCC )
  {
    on_cv = FALSE;
    BSprptoncv(&mess,bc,poles,sol_u,&on_cv);

    if( mess == BSSUCC  &&  on_cv )
    {
      MAsubvc(&mess,&poles[0],&poles[3],ln_vc);                      
      MAuvctnbc(&mess,bc,sol_u,bcpt,t);           /*get tangent vector to bc*/
      MAcrossvc(&mess,ln_vc,t,z);                 /* get normal to circle   */

      if( *center_diam_flag )
      {
        poles[3] = (poles[3] + poles[0])/2.0;
        poles[4] = (poles[4] + poles[1])/2.0;
        poles[5] = (poles[5] + poles[2])/2.0;
      }

      if( mess != MAIDGENRAT )
      {
        MA2ptdis(&mess,&poles[0],&poles[3],&rad);
        MAcrrcconstr(&mess,&rad,&poles[3],z,bc_circle);
      }
    }
    else
    {
      *msg = MSFAIL;
    }
  }
  else
  {
    *msg = MSFAIL;
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
