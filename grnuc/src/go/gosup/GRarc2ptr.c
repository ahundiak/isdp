/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRarc2ptr
 
     Abstract: This routine returns one of four possible arcs through
	      two points with a given radius. The criteria that det-
	      ermines which arc to return is that it is counter-clockwise
	      wrt a viewing vector and its center is closest to an input
	      select point (approximate center).

-----
%SC%

     VALUE = GRarc2ptr(message,center,st_pt,sw_pt,radius,view_vc,arc)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     center	  IGRpoint	 select point closest to desired arc
				 center
     st_pt	  IGRpoint	 start point of arc
     sw_pt	  IGRpoint	 sweep point of the arc
     radius	  IGRdouble	 radius of the arc
     view_vc  	  IGRvector	 viewing vector
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message	  IGRlong	 return code:
					MSSUCC - successful
					MASDGENRAT - start and sweep
				 point were identical

     arc	  IGRbsp_curve	 constructed arc

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - arc found 
                        FALSE- arc not found

-----
%MD%

     MODULES INVOKED:
		     MAarr2ptconstr
		     MA2pt2dis
		     MAdotvc
		     MAbccopy
-----
%NB%

     NOTES:
	   The arc returned will always be oriented counter-clockwise
	  wrt the viewing vector.
	   The input center is actually only used to choose the arc
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
 This routine first gets all four possible arcs defined by the radius
and start and sweep points. Then it finds the two whose center is 
closest to the input center. Finally, it decides based on the sign of
the dot product of the arc normals and the viewing vector which arc
to return as the arc with a counter-clockwise orientation.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"

extern    IGRboolean    MAarr2ptconstr();
extern    IGRboolean    MA2pt2dis();
extern    IGRboolean    MAdotvc();
extern    IGRboolean    MAbccopy();

IGRboolean GRarc2ptr(message,center,st_pt,sw_pt,radius,view_vc,arc)

	   IGRlong	       *message;	/* return code		      */
	   IGRpoint		center;		/* select point		      */
	   IGRpoint		st_pt;		/* start point of arc	      */
	   IGRpoint		sw_pt;		/* stop point of arc	      */
	   IGRdouble	       *radius;		/* radius of the arc	      */
	   IGRvector		view_vc;	/* viewing vector	      */
	   struct IGRbsp_curve *arc;		/* the constructed arc	      */

{
  struct IGRbsp_curve arcs[4];			/* four arcs		      */

  IGRdouble poles1[21],knots1[10],wts1[7];	/* for arc[0]		      */
  IGRdouble poles2[21],knots2[10],wts2[7];	/* for arc[1]		      */
  IGRdouble poles3[21],knots3[10],wts3[7];	/* for arc[2]		      */
  IGRdouble poles4[21],knots4[10],wts4[7];	/* for arc[3]		      */
  IGRdouble centers[6];				/* center of arcs	      */
  IGRdouble normals[12];			/* arc normal vectors	      */
  IGRdouble dis1,dis2;				/* distance to centers        */
  IGRdouble dot_pro;				/* dot product		      */

  IGRlong mess;					/* return code		      */

  IGRshort i;					/* index		      */



  *message = MSSUCC;

  arcs[0].poles =   poles1;			/* init arcs		      */
  arcs[0].knots =   knots1;
  arcs[0].weights = wts1;

  arcs[1].poles   = poles2;
  arcs[1].knots   = knots2;
  arcs[1].weights = wts2;

  arcs[2].poles   = poles3;
  arcs[2].knots   = knots3;
  arcs[2].weights = wts3;

  arcs[3].poles   = poles4;
  arcs[3].knots   = knots4;
  arcs[3].weights = wts4;
						/* get both defined arcs      */
  if( MAarr2ptconstr(message,radius,st_pt,sw_pt,view_vc,arcs,centers,normals) )
    {
      MA2pt2dis(&mess,center,centers,&dis1);	/* compute distance to centers*/
      MA2pt2dis(&mess,center,&centers[3],&dis2);

      if( dis1 <= dis2 )			/* set index to choose arc    */
        {
          i = 0;
        }
      else
        {
	  i = 2;
	}

      MAdotvc(&mess,&normals[3*i],view_vc,&dot_pro);

      if( dot_pro >= 0.0 )			/* clockwise wrt view_vc?     */
	{
	  MAbccopy(&mess,&arcs[i],arc);
	}
      else
	{
	  MAbccopy(&mess,&arcs[i+1],arc);
	}
    }

  return( *message & 1 );

}/* This has been an R.D.H. production!!! */  
