/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRcbclnextend
 
     Abstract: This routine takes a B-spline line with two poles and
	clips the extension of the line with an input box to get
	a "semi-infinite" line. The extension may be done in place.
-----
%SC%

     VALUE = GRcbclnextend(msg,bc_ln,low_point,high_point,ext_bc_ln)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc_ln	  IGRbsp_curve	 B-spline line to clip against the
				 design cube
     low_point	  IGRpoint	 low point of the box
     high_point	  IGRpoint	 high point of the box

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MANOSOLUTION - line did not
				 intersect the cube
					MAIDGENRAT - line is a point
				 inside box, clip was completed but
				 no extension was done.

     ext_bc_ln	  IGRbsp_curve	 extended B-spline line

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - line clipped successfully
                        FALSE- line not clipped

-----
%MD%

     MODULES INVOKED:
		MAtlncbclip
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
 This routine calls MAlncbclip to clip the line against the box
and then sets up a polyline which is converted to a B-spline curve.
If the clip routine returns MAIDGENRAT in the return code, the
input line was a point inside the box. In this case, this routine
creates the extended line as a point and returns MAIDGENRAT as
the return code.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "maerr.h"
#include "msdef.h"

IGRboolean GRcbclnextend(msg,bc_ln,low_point,high_point,ext_bc_ln)

	   IGRlong             *msg;		/* return code		     */
	   struct IGRbsp_curve *bc_ln;		/* line to extend	     */
	   IGRpoint		low_point;	/* low point of box	     */
	   IGRpoint		high_point;	/* high point of box	     */
	   struct IGRbsp_curve *ext_bc_ln;	/* extended line	     */

{
  struct IGRline line;				/* bc_ln in IGR format       */
  struct IGRline ext_line;			/* extended line	     */
  struct IGRpolyline py;			/* ext_bc_ln in IGR format   */

  IGRpoint p0,p1;				/* points for ext_line	     */
  IGRdouble points[12];				/* points for py	     */
  IGRdouble mint,maxt;				/* t parameters		     */


  *msg = MSSUCC;

  line.point1 = &bc_ln->poles[0];
  line.point2 = &bc_ln->poles[3];

  ext_line.point1 = p0;
  ext_line.point2 = p1;

  MAtlncbclip(msg,&line,low_point,high_point,&mint,&maxt,&ext_line);

  if( 1 & *msg )
    {
      if( mint <= 0.0 )
	{
	  points[0] = p0[0];
	  points[1] = p0[1];
 	  points[2] = p0[2];

	  if( maxt <= 0.0 )
	    {
	      points[3] = p1[0];
	      points[4] = p1[1];
	      points[5] = p1[2];

	      points[6] = line.point1[0];
 	      points[7] = line.point1[1];
	      points[8] = line.point1[2];

	      points[9] = line.point2[0];
	      points[10] = line.point2[1];
	      points[11] = line.point2[2];
	    }
	  else
	    {
	      if( maxt >= 1.0 )
		{
		  points[3] = line.point1[0];
	      	  points[4] = line.point1[1];
	 	  points[5] = line.point1[2];

		  points[6] = line.point2[0];
		  points[7] = line.point2[1];
		  points[8] = line.point2[2];

		  points[9] = p1[0];
		  points[10] = p1[1];
		  points[11] = p1[2];
		}
	      else
		{
		  points[3] = line.point1[0];
	      	  points[4] = line.point1[1];
	 	  points[5] = line.point1[2];

		  points[6] = p1[0];
		  points[7] = p1[1];
		  points[8] = p1[2];

		  points[9] = line.point2[0];
		  points[10] = line.point2[1];
		  points[11] = line.point2[2];
		}
	    }  
	}
      else
	{
	  if( 0.0 <= mint  &&  mint <= 1.0 )      
	    {
	      points[0] = line.point1[0];
	      points[1] = line.point1[1];
	      points[2] = line.point1[2];

	      points[3] = p0[0];
	      points[4] = p0[1];
	      points[5] = p0[2];

	      if( maxt >= 1.0 )
		{
		  points[6] = line.point2[0];
		  points[7] = line.point2[1];
		  points[8] = line.point2[2];

		  points[9] = p1[0];
	 	  points[10] = p1[1];
		  points[11] = p1[2];
		}
	      else
		{
		  points[6] = p1[0];
		  points[7] = p1[1];
		  points[8] = p1[2];

		  points[9] = line.point2[0];
		  points[10] = line.point2[1];
		  points[11] = line.point2[2];
		}
	    }
	  else
	    {
	      points[0] = line.point1[0];
	      points[1] = line.point1[1];
	      points[2] = line.point1[2];

	      points[3] = line.point2[0];
	      points[4] = line.point2[1];
	      points[5] = line.point2[2];

	      points[6] = p0[0];
	      points[7] = p0[1];
	      points[8] = p0[2];

	      points[9] = p1[0];
	      points[10] = p1[1];
	      points[11] = p1[2];
	    }
	}

      py.num_points = 4;
      py.points = points;

      MAplpytobc(msg,&py,ext_bc_ln);
    }

  return( *msg == MSSUCC  ||  *msg == MAIDGENRAT );

}/* This has been an R.D.H. production!!! */
