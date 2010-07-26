/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GOcdtto2bc
 
     Abstract: This routine finds a circle tangent to two B-spline
	      curves given the u parameters of the approximate points 
	      of tangency. The solution tangent points are used as 
	      the diameter points of the circle.

-----
%SC%

     VALUE = GOcdtto2bc(msg,bc1,bc2,tent_pt1,tent_pt2,sol_u1,sol_u2,bc_circle)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc1	  IGRbsp_curve   first B-spline curve
     bc2	  IGRbsp_curve   second B-spline curve
     tent_pt1	  IGRpoint  	 approximate tangent point bc1
     tent_pt2	  IGRpoint  	 approximate tangent point bc2
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure of math
				 algorithm

     sol_u1	  IGRdouble	 u par of tangent point bc1
     sol_u2	  IGRdouble	 u par of tangent point bc2
     bc_circle	  IGRbsp_curve	 B-spline circle tangent to bc
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - tangent circle found
                        FALSE- circle not found

-----
%MD%

     MODULES INVOKED:
		MAulp2bc
		MAsubvc
	        MAuvctnbc
		MAcrossvc
		MAcrdconstr

-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  12/9/86  : Creation date.
	RDH  07/07/89 : add call to BSlnn2cvs
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine calls a math routine to find the line perpendicular to
the curves given the u pars of the approximate tangent points.
The line is a diameter of the circle. The direction vector of the 
line and the tangent vector of the first curve at the tangent point
are used to form the vector normal to the plane of the circle.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "maerr.h"
#include "msdef.h"
#include "bserr.h"

IGRboolean GOcdtto2bc(msg,bc1,bc2,tent_pt1,tent_pt2,sol_u1,sol_u2,bc_circle)

	   IGRlong               *msg;		/* return code		     */
	   struct IGRbsp_curve   *bc1;		/* B-spline curve	     */
	   struct IGRbsp_curve   *bc2;		/* B-spline curve	     */
	   IGRpoint		 tent_pt1;	/* approximate tan pt bc1    */
	   IGRpoint		 tent_pt2;	/* approximate tan pt bc2    */
	   IGRdouble		 *sol_u1;	/* u par of tan pt bc1       */
	   IGRdouble		 *sol_u2;	/* u par of tan pt bc2       */
	   struct IGRbsp_curve   *bc_circle;	/* tangent circle	     */

{
  struct IGRbsp_curve ln;			/* perpendicular line	     */

  IGRpoint bcpt;				/* tangent point	     */

  IGRvector ln_vc;				/* direction vector of line  */
  IGRvector t;					/* tangent vector	     */
  IGRvector z;					/* normal vector to circle   */

  IGRdouble poles[6];				/* poles for ln		     */
  IGRdouble knots[4];				/* knots for ln		     */

  IGRlong mess;					/* return code		     */


  *msg = MSSUCC;

  ln.poles = poles;
  ln.knots = knots;

  BSlnn2cvs(&mess,bc1,bc2,tent_pt1,tent_pt2,&ln,sol_u1,sol_u2);

  if( mess == BSSUCC )
  {
    MAsubvc(&mess,&poles[0],&poles[3],ln_vc);                      
    MAuvctnbc(&mess,bc1,sol_u1,bcpt,t);	           /*get tangent vector to bc*/
    MAcrossvc(&mess,ln_vc,t,z);                    /* get normal to circle   */

    if( mess != MAIDGENRAT )
    {
      MAcrdconstr(msg,poles,z,bc_circle);
    }
    else
    {
      *msg = MASDGENRAT;
    }
  }
  else
  {
    *msg = MSFAIL;
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
