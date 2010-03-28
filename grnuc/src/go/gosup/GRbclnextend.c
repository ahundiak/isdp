/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRbclnextend
 
     Abstract: This routine takes a B-spline line with two poles and
	clips the extension of the line with the design cube to get
	a "semi-infinite" line. The extension may be done in place.
-----
%SC%

     VALUE = GRbclnextend(msg,bc_ln,ext_bc_ln)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc_ln	  IGRbsp_curve	 B-spline line to clip against the
				 design cube
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MANOSOLUTION - line did not
				 intersect the cube
					MASDGENRAT - line is a point

     ext_bc_ln	  IGRbsp_curve	 extended B-spline line

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - line clipped successfully
                        FALSE- line not clipped

-----
%MD%

     MODULES INVOKED:
		MAlncbclip
		MApytobc
-----
%NB%

     NOTES:
            The input and output line may be the same data structure
	   if the line has room for 4 poles and 6 knots.

-----

%CH%
     CHANGE HISTORY:
	
	RDH  07/10/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine calls MAlncbclip to clip the line against the design
cube and then sets up a polyline which is converted to a B-spline
curve.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "godef.h"

IGRboolean GRbclnextend(msg,bc_ln,ext_bc_ln)

	   IGRlong             *msg;		/* return code		     */
	   struct IGRbsp_curve *bc_ln;		/* line to extend	     */
	   struct IGRbsp_curve *ext_bc_ln;	/* extended line	     */

{
  struct IGRline line;				/* bc_ln in IGR format       */
  struct IGRline ext_line;			/* extended line	     */
  struct IGRpolyline py;			/* ext_bc_ln in IGR format   */

  IGRpoint p0,p1;				/* points for ext_line	     */
  IGRpoint diag1,diag2;				/* diagonal points of cube   */
  IGRdouble points[12];				/* points for py	     */

  
  *msg = MSSUCC;

  line.point1 = &bc_ln->poles[0];
  line.point2 = &bc_ln->poles[3];

  ext_line.point1 = p0;
  ext_line.point2 = p1;

  diag1[0] = GRDGNLIMITS_MIN_D;
  diag1[1] = GRDGNLIMITS_MIN_D;
  diag1[2] = GRDGNLIMITS_MIN_D;
  
  diag2[0] = GRDGNLIMITS_MAX_D;
  diag2[1] = GRDGNLIMITS_MAX_D;
  diag2[2] = GRDGNLIMITS_MAX_D;

  if( MAlncbclip(msg,&line,diag1,diag2,&ext_line) )
    {
      py.points = points;

      py.points[0] = ext_line.point1[0];
      py.points[1] = ext_line.point1[1];
      py.points[2] = ext_line.point1[2];

      py.points[3] = line.point1[0];
      py.points[4] = line.point1[1];
      py.points[5] = line.point1[2];

      py.points[6] = line.point2[0];
      py.points[7] = line.point2[1];
      py.points[8] = line.point2[2];

      py.points[9] = ext_line.point2[0];
      py.points[10] = ext_line.point2[1];
      py.points[11] = ext_line.point2[2];

      py.num_points = 4;

      MAplpytobc(msg,&py,ext_bc_ln);
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
