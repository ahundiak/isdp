/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GOarcptrdcv
 
     Abstract: 
		This routine finds an arc or circle with a given radius
		through a given point an tangent to a given curve. A flag
		indicates whether the arc or full circle is to be returned.
		
-----
%SC%

     VALUE = GOarcptrdcv(msg,pt,rad,bc,u,tanpt,center,view,flag,out_geom)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     pt		  IGRpoint	 point incident with arc/circle
     rad	  IGRdouble	 radius of arc/circle
     bc		  IGRbsp_curve	 B-spline curve arc/circle is tangent	
     				 to
     u		  IGRdouble	 parameter of approximate tangent pt
     tanpt	  IGRpoint	 approximate tangent point
     center	  IGRpoint	 approximate center of arc/circle
     view	  IGRvector	 vector to establish cw,ccw orientation
     flag	  IGRboolean	 return arc/circle (TRUE/FALSE)
          
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure to find arc  
					MSINARG - invalid input, 
				 points are not distinct

     out_geom	  IGRbsp_curve	 desired arc/circle
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - arc found
                        FALSE- no arc found

-----
%MD%

     MODULES INVOKED:
		     MAcrossvc
		     MAdotvc
		     BSarcptrdcv
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
 This routine forms two vectors from the input points and finds the
dot product of their cross product with the viewing vector to set
a flag for the math routine called which attempts to find the
desired arc.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "madef.h"
#include "msdef.h"
#include "bserr.h"

IGRboolean GOarcptrdcv(msg,pt,rad,bc,u,tanpt,center,view,flag,out_geom)

	   IGRlong             *msg;		/* return code		     */
	   IGRpoint		pt;		/* point incident with geom  */
	   IGRdouble	       *rad;		/* radius of geom	     */
	   struct IGRbsp_curve *bc;		/* curve arc is tangent to   */
	   IGRdouble	       *u;		/* u par of approx tangent pt*/
	   IGRpoint		tanpt;		/* app tangent point on bc   */
	   IGRpoint		center;		/* app center of desired arc */
	   IGRvector		view;		/* vector used to find ccw   */
	   IGRboolean	       *flag;		/* arc/circle indicator	     */
	   struct IGRbsp_curve *out_geom;	/* tangent arc/circle	     */

{
  IGRpoint origin;				/* input - approx center,    */
  						/* output - determined center*/
  
  IGRvector normal;
  
  IGRdouble sol_u;
  
  IGRint  bs_flag;				/* small/large arc flag      */
  IGRboolean ccw;
  IGRlong mess;					/* return code		     */


  bs_flag = 1;

  if( !bc->rational  &&  bc->order == 2 )
  {
    bc->planar = FALSE;
  }

  origin[0] = center[0];
  origin[1] = center[1];
  origin[2] = center[2];

  BSarcptrdcv(bc,pt,*u,*rad,bs_flag,normal,origin,&sol_u,tanpt,out_geom,
	      &mess);

  if( mess == BSSUCC )
  {
    if( !( *flag ) )
    {
      MAcrrcconstr(&mess,rad,origin,normal,out_geom);
    }
    else
    {
      ccw = TRUE;

      BSac2ptctvc(pt,origin,tanpt,view,ccw,out_geom,&mess);

      if( mess != BSSUCC )
      {
      	*msg = MSFAIL;
      }
    }
  }
  else
  {
    *msg = MSFAIL;
  }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
