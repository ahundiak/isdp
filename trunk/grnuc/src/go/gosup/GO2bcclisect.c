/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GO2bcclisect
 
     Abstract: This routine finds the closest intersection of two 
	      B-spline curves to a line.
-----
%SC%
	  
     VALUE = GO2bcclisect(msg,bc1,bc2,&ln,&tol,ipoint,&u1,&u2)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc1	  IGRbsp_curve	 B-spline curve
     bc2	  IGRbsp_curve	 B-spline curve
     ln		  IGRline	 line to indicate desired curve
     tol	  IGRdouble	 intersection tolerance
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure     
     ipoint	  IGRpoint	 intersection point
     u1		  IGRdouble	 u parameter for curve1
     u2		  IGRdouble	 u parameter for curve2

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - intersection point found
                        FALSE- no intersection found

-----
%MD%

     MODULES INVOKED:
		BScvcv_int
		MAptln2dis
-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  09/26/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine calls a math routine to find all intersections and
returns the point closest to the input line.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "maerr.h"

IGRboolean GO2bcclisect(msg,bc1,bc2,ln,tol,ipoint,u1,u2)

	IGRlong 	    *msg;
	struct IGRbsp_curve *bc1;
	struct IGRbsp_curve *bc2;
	struct IGRline	    *ln;
	IGRpoint	     ipoint;
	IGRdouble	    *u1;
	IGRdouble	    *u2;

{
  IGRdouble *int_pts;
  IGRdouble *end_pts;
  IGRdouble *over0, *over1;
  IGRdouble *par0, *par1;
  IGRdouble dis;
  IGRdouble min_dis;

  IGRlong mess;

  IGRint i;
  IGRint n_int, n_over;

  IGRlong bsmsg;


  *msg = MSSUCC;

  int_pts = 0;
  end_pts = 0;
  over0 = 0;
  over1 = 0;
  par0 = 0;
  par1 = 0;
  n_int = 0;
  n_over = 0;

  if( BScvcv_int(&bsmsg, bc1, bc2, &n_int, &int_pts, &par0, &par1, 
		 &n_over, &end_pts, &over0, &over1) )
    {
      if( n_int )
	{
	  MAptln2dis(&mess, int_pts, ln, &min_dis);

	  ipoint[0] = int_pts[0];
	  ipoint[1] = int_pts[1];
	  ipoint[2] = int_pts[2];

	  *u1 = par0[0];
	  *u2 = par1[0];
	}
      else
	{
	  if( n_over )
	  {
	    MAptln2dis(&mess, end_pts, ln, &min_dis);

	    ipoint[0] = end_pts[0];
	    ipoint[1] = end_pts[1];
	    ipoint[2] = end_pts[2];

	    *u1 = over0[0];
	    *u2 = over1[0];
	  }
	}

      for(i = 0; i < n_int; ++i)
         {
	   MAptln2dis(&mess, &int_pts[i * 3], ln, &dis);

	   if( dis < min_dis )
	     {
	       ipoint[0] = int_pts[i * 3];
	       ipoint[1] = int_pts[i * 3 + 1];
	       ipoint[2] = int_pts[i * 3 + 2];

	       *u1 = par0[i];
	       *u2 = par1[i];

	       min_dis = dis;
	     }
	 }

      for(i = 0; i < n_over; ++i )
	 {
	   MAptln2dis(&mess, &end_pts[i * 3], ln, &dis);

	   if( dis < min_dis )
	     {
	       ipoint[0] = end_pts[i * 3];
	       ipoint[1] = end_pts[i * 3 + 1];
	       ipoint[2] = end_pts[i * 3 + 2];

	       *u1 = over0[i];
	       *u2 = over1[i];

	       min_dis = dis;
	    }
	 }

      if( n_int == 0  &&  n_over == 0 )
      {
      	*msg = MANOSOLUTION;
      }
    }
  else
    {
      *msg = MSFAIL;
    }

  if( int_pts )
    {
      free( int_pts );
    }
  if( end_pts )
    {
      free( end_pts );
    }
  if( par0 )
    {
      free( par0 );
    }
  if( par1 )
    {
      free( par1 );
    }
  if( over0 )
    {
      free( over0 );
    }
  if( over1 )
    {
      free( over1 );
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
