/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GOlpfrbs
 
     Abstract: This routine finds a line of unit length from a point
	      on a B-spline surface which is perpendicular to the surface.

-----
%SC%

     VALUE = GOlpfrbs(msg,bs,pt,u,v,bc_ln)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     bs		  IGRbsp_surface B-spline surface
     pt		  IGRpoint	 point on surface line emanates from
     u		  IGRdouble	 u parameter of point
     v		  IGRdouble	 v parameter of point
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure of math
				 algorithm

     bc_ln	  IGRbsp_curve	 B-spline line perpendicular from point
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - perpendicular line found
                        FALSE- line not found

-----
%MD%

     MODULES INVOKED:
		BSsfarrevn
		MAaddvc

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
 This routine evaluates the surface normal vector at the (u,v) and
then it adds the normal to the input point and constructs a B-spline
line from the two point.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "bserr.h"


IGRboolean GOlpfrbs(msg,bs,pt,u,v,bc_ln)

	   IGRlong               *msg;		/* return code		     */
	   struct IGRbsp_surface *bs;		/* B-spline surface	     */
	   IGRpoint		  pt;		/* point on surface	     */
	   IGRdouble		 *u;		/* u parameter of pt	     */
	   IGRdouble		 *v;		/* v parameter of pt	     */
	   struct IGRbsp_curve   *bc_ln;	/* perpendicular line	     */

{
  IGRpoint pt2;					/* end point of line	     */

  IGRdouble points[1][1][3];			/* surface point at (u,v)    */
  IGRdouble normals[1][1][3];			/* normal at (u,v)	     */

  IGRlong mess;					/* return code		     */
  
  IGRint numu,numv;				/* number of parametrs	     */
  IGRint bs_rc;					/* return code		     */



  *msg = MSSUCC;

  numu = numv = 1;

  BSsfarrevn(&bs_rc,bs,numu,u,numv,v,points,normals);

  if( bs_rc == BSSUCC )
    {
      MAaddvc(&mess,pt,&normals[0][0][0],pt2);

      MA2pttobc(&mess,pt,pt2,bc_ln);
    }
  else
    {
      *msg = MSFAIL;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
