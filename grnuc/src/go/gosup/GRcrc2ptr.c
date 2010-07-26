/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRcrc2ptr
 
     Abstract: This routine returns one of two possible circles circles through
	      two points with a given radius. The circle returned is the
	      circle whose center is closest to the input center (select
	      point).

-----
%SC%

     VALUE = GRcrc2ptr(message,center,pt1,pt2,radius,z_vect,circle)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     center	  IGRpoint	 select point closest to desired circle
				 center
     pt1	  IGRpoint	 point on the circles
     pt2	  IGRpoint	 point on the circles
     radius	  IGRdouble	 radius of the circles
     z_vect  	  IGRvector	 vector normal to plane of desired circle
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message	  IGRlong	 return code:
					MSSUCC - successful
					MASDGENRAT - start and sweep
				 point were identical

     circle	  IGRbsp_curve	 constructed circle

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - circle found 
                        FALSE- circle not found

-----
%MD%

     MODULES INVOKED:
		     MAcrr2ptconstr
		     MA2pt2dis
		     MAbccopy();

-----
%NB%

     NOTES:
	   The input center is actually only used to choose the circle
	  whose center is closest to it and need not be anywhere in 
	  the vicinity of the true centers.
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  04/22/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"

extern    IGRboolean    MAcrr2ptconstr();
extern    IGRboolean    MA2pt2dis();
extern    IGRboolean    MAbccopy();

IGRboolean GRcrc2ptr(message,center,pt1,pt2,radius,z_vect,circle)

	   IGRlong	       *message;	/* return code		      */
	   IGRpoint		center;		/* select point		      */
	   IGRpoint		pt1;		/* start point of circle      */
	   IGRpoint		pt2;		/* stop point of circle	      */
	   IGRdouble	       *radius;		/* radius of the circle	      */
	   IGRvector		z_vect;		/* viewing vector	      */
	   struct IGRbsp_curve *circle;		/* the constructed circle     */

{
  struct IGRbsp_curve circles[2];		/* four circles		      */

  IGRdouble poles1[21],knots1[10],wts1[7];	/* for circle[0]	      */
  IGRdouble poles2[21],knots2[10],wts2[7];	/* for circle[1]	      */
  IGRdouble centers[6];				/* center of circles	      */
  IGRdouble dis1,dis2;				/* distance to centers        */

  IGRlong mess;					/* return code		      */


  
  *message = MSSUCC;

  circles[0].poles =   poles1;			/* init circles		      */
  circles[0].knots =   knots1;
  circles[0].weights = wts1;

  circles[1].poles   = poles2;
  circles[1].knots   = knots2;
  circles[1].weights = wts2;

						/* get both defined circles   */
  if( MAcrr2ptconstr(message,radius,pt1,pt2,z_vect,circles,centers) )
    {
      MA2pt2dis(&mess,center,centers,&dis1);	/* compute distance to centers*/
      MA2pt2dis(&mess,center,&centers[3],&dis2);

      if( dis1 <= dis2 )			/* set index to choose circle */
        {
	  MAbccopy(&mess,&circles[0],circle);
        }
      else
        {
	  MAbccopy(&mess,&circles[1],circle);
	}
    }

  return( *message & 1 );

}/* This has been an R.D.H. production!!! */  
