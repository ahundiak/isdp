/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GOlptobs
 
     Abstract: This routine finds a line perpendicular to a surface from
	      a point in space.

-----
%SC%

     VALUE = GOlptobs(msg,bs,pt,u,v,sol_u,sol_v,bc_ln)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bs		  IGRbsp_surface B-spline surface
     pt		  IGRpoint	 point in space
     u		  IGRdouble	 u parameter of approximate perp point
     v		  IGRdouble	 v parameter of approximate perp point
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure of math
				 algorithm

     sol_u	  IGRdouble	 solution u parameter
     sol_v	  IGRdouble	 solution v parameter
     bc_ln	  IGRbsp_curve	 B-spline line perpendicular to bs
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - perpendicular line found
                        FALSE- line not found

-----
%MD%

     MODULES INVOKED:
		BSptperpsfa
		MA2pttobc

-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  07/17/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine calls a math routine to find the point on the surface
and another routine to format the B-spline line from two points.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "bserr.h"


IGRboolean GOlptobs(msg,bs,pt,u,v,sol_u,sol_v,bc_ln)

	   IGRlong               *msg;		/* return code		     */
	   struct IGRbsp_surface *bs;		/* B-spline surface	     */
	   IGRpoint		  pt;		/* point in space	     */
	   IGRdouble		 *u;		/* u parameter of approx pt  */
	   IGRdouble		 *v;		/* v parameter of approx pt  */
	   IGRdouble		 *sol_u;	/* u parameter of soln pt    */
	   IGRdouble		 *sol_v;	/* v parameter of soln pt    */
	   struct IGRbsp_curve   *bc_ln;	/* perpendicular line	     */

{
  IGRpoint pt2;					/* end point of line	     */

  IGRint n;

  IGRdouble length;				/* length of solution line   */

  IGRlong mess;					/* return code		     */


  *msg = MSSUCC;
  n = 0;

  BSptperpsfa(bs,pt,*u,*v,&n,sol_u,sol_v,pt2,&length,&mess);

  if( mess == BSSUCC  &&  n == 1 )
    {
      MA2pttobc(&mess,pt,pt2,bc_ln);
    }
  else
    {
      *msg = MSFAIL;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
