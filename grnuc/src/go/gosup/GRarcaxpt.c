/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRarcaxpt
 
     Abstract: This routine constructs an arc with a given center and
	      endpoint of the semi-major axis with a sweep angle which
	      is determined by another point. The arc which is returned
	      will be counter-clockwise wrt an input viewing vector.

-----
%SC%

     VALUE = GRarcaxpt(message,center,smj_pt,pt,vc,arc)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     center	  IGRpoint	 the center of the arc
     smj_pt	  IGRpoint	 endpoint of semi-major axis
     pt	 	  IGRpoint	 point which determines the sweep
	            		 angle     
     vc	 	  IGRvector	 viewing vector used to determine
				 what is "counter-clockwise"
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message	  IGRlone	 return code:
					MSSUCC - successful
					MADGENRAT - points were co-
				 linear, rotation matrix is arbitrary
					GRILLDEFINITION - illegal input

     arc	  IGRbsp_curve	 output arc
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - arc found
                        FALSE- no arc found

-----
%MD%

     MODULES INVOKED:
		     MAarcsmptconstr
		     MAdotvc
		     MAbccopy
-----
%NB%

     NOTES:
	    The arc returned is always counter-clockwise with respect
	   to the viewing vector.            

	    The storage for the arc is assumed to be provided by the
	   calling routine. Allow for 7 poles, 10 knots and 7 weights.

	    The start and stop points must be different than the center.
	   In this case, this routine sets the return code to
	   GRILLDEFINITION and exits.
-----

%CH%
     CHANGE HISTORY:
	
	RDH  04/21/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine calls MAarcsmptconstr to get the two arcs that the
center , semi-major point and sweep point defines and returns the
arc whose normal vector produces a positive quantity as the dot 
product with the viewing vector.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "grerr.h"
#include "msdef.h"

extern    IGRboolean    MA2pt2dis();
extern    IGRboolean    MAarcsmptconstr();
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MAbccopy();

IGRboolean GRarcaxpt(message,center,smj_pt,pt,vc,arc)

	   IGRlong	       *message;	/* return code		     */
	   IGRpoint		center;		/* center of the arc	     */
	   IGRpoint		smj_pt;		/* semi-major end point	     */
	   IGRpoint		pt;		/* point to determin sweep   */
	   IGRvector		vc;		/* viewing vector	     */
	   struct IGRbsp_curve *arc;		/* output arc		     */

{
  struct IGRbsp_curve arcs[2];			/* defined arcs		     */

  IGRvector n1,n2;				/* arc normal vectors	     */

  IGRdouble dis1, dis2;				/* distances to origin	     */
  IGRdouble poles1[21],poles2[21];		/* poles		     */
  IGRdouble knots1[10],knots2[10];		/* knots		     */
  IGRdouble wts1[7],wts2[7];			/* weights		     */
  IGRdouble dot_pro;				/* dot product		     */

  IGRlong mess;					/* return code		     */



  *message = MSSUCC;

  MA2pt2dis(&mess,center,smj_pt,&dis1);
  MA2pt2dis(&mess,center,pt,&dis2);

  if( dis1 != 0.0  &&  dis2 != 0.0 )
    {
      arcs[0].poles =   poles1;			/* init arcs		     */
      arcs[0].knots =   knots1;
      arcs[0].weights = wts1;

      arcs[1].poles   = poles2;
      arcs[1].knots   = knots2;
      arcs[1].weights = wts2;
						/* get both defined arcs     */
      if( MAarcsmptconstr(&mess,center,smj_pt,pt,vc,arcs,n1,n2) )
        {
          MAdotvc(&mess,vc,n1,&dot_pro);

          if( dot_pro >= 0.0 )
	    {
	      MAbccopy(&mess,&arcs[0],arc);
	    }
          else
	    {
	      MAbccopy(&mess,&arcs[1],arc);
	    }
        }
      else
	{
	  *message = MSFAIL;
	}
    }
  else
    {
      *message = GRILLDEFINITION;
    }

  return( *message & 1 );

}/* This has been an R.D.H. production!!! */
