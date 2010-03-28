/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GObcsclisect
 
     Abstract: This routine finds the closest intersection of a
	      B-spline curve and surface to a line.
-----
%SC%
	  
     VALUE = GObcsclisect(msg,bc,bs,&ln,&tol,ipoint,&u1,&u2,&u3)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bc		  IGRbsp_curve	 B-spline curve
     bs		  IGRbsp_surface B-spline surface
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
					MANOSOLUTION - no intersection 
					
     ipoint	  IGRpoint	 intersection point
     u1		  IGRdouble	 u parameter for curve
     u2		  IGRdouble	 parameter for surface
     u3		  IGRdouble	 parameter for surface
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - intersection point found
                        FALSE- no intersection found

-----
%MD%

     MODULES INVOKED:
		BScv_sf_int
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


IGRboolean GObcsclisect(msg,bc,bs,ln,tol,ipoint,u1,u2,u3)

	IGRlong 	    *msg;
	struct IGRbsp_curve *bc;
	struct IGRbsp_surface  *bs;
	struct IGRline	    *ln;
	IGRpoint	     ipoint;
	IGRdouble	    *u1;
	IGRdouble	    *u2;
	IGRdouble	    *u3;

{
  IGRdouble *int_pts;
  IGRdouble *tpar,*par0, *par1;
  IGRdouble dis;
  IGRdouble min_dis;

  IGRint i;
  IGRint n_int;

  IGRlong mess;
  IGRlong bsmsg;


  *msg = MSSUCC;

  int_pts = 0;
  tpar = 0;
  par0 = 0;
  par1 = 0;
  n_int = 0;

  if( BScv_sf_int(&bsmsg, bc, bs, &n_int, &int_pts, &tpar, &par0, &par1) )
  {
    if( n_int )
    {
      MAptln2dis(&mess, int_pts, ln, &min_dis);

      ipoint[0] = int_pts[0];
      ipoint[1] = int_pts[1];
      ipoint[2] = int_pts[2];

      *u1 = tpar[0];
      *u2 = par0[0];
      *u3 = par1[0];

      for(i = 1; i < n_int; ++i)
      {
        MAptln2dis(&mess, &int_pts[i * 3], ln, &dis);

        if( dis < min_dis )
        {
          ipoint[0] = int_pts[i * 3];
          ipoint[1] = int_pts[i * 3 + 1];
          ipoint[2] = int_pts[i * 3 + 2];

          *u1 = tpar[i];
          *u2 = par0[i];
          *u3 = par1[i];

          min_dis = dis;
        }
      }
    }
    else
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
  if( tpar )
    {
      free( tpar );
    }
  if( par0 )
    {
      free( par0 );
    }
  if( par1 )
    {
      free( par1 );
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
