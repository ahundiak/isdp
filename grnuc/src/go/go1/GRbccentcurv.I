/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRcentcurv

     Abstract: This routine finds center of curvature at a given parameter 
	on a B-spline element.

-----
%SC%    

	 GRcentcurv( msg,mat_type,matrix,parms,center )
     
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     mat_type	  IGRshort	 environment matrix type
     matrix	  IGRmatrix	 environment matrix
     parms	  struct GRparms parameters
     
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - failure
					MASDGENRAT - curvature does
				 not exist or poles did not allow
				 for the fitting of a conic.

     center	  IGRpoint	 center of curvature
     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     BSrdcencrcv
	     BSarcofpts	     
     Methods:
	     GRgenabsg	     
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
		This routine will return the center of curvature as 
	evaluated "from the left" at the input parameter.	   
		If the curve is linear, an arc is fitted through the
	points surrounding the point at which the curvature is being
	extracted. The tolerance used for the fit is the chord height 
	tolerance in the dpb. This happens if the number of poles is
	greater than 4. If it is less than 4, then a GRcenter 
	method is invoked.

-----
%CH%

     CHANGE HISTORY:
	
	RDH     01/20/88 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This routine gets the abstract geometry of the object and if the
curve is not linear it calls BSrdcencrcv to find the needed 
information. If the curve is linear, BSarcofpts is called to fit
an arc through the points around the input parameter for the call
to BSrdcencrcv. If there is not enough poles to call BSarcofpts,
then a GRcenter message is sent.

----*/
/*EH*/


class implementation GRbspline;

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "grdpbdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "madef.h"
#include "mapriv.h"
#include "bserr.h"
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"

method GRcentcurv( IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		   struct GRparms *parms; IGRpoint center )

{
  struct IGRbsp_curve *bc;		/* abstract geom pointer	*/
  struct IGRbsp_curve arc;		/* fitted arc			*/

  IGRpoint  pt;				/* point on curve for linear	*/

  IGRdouble poles[30];			/* poles for arc		*/
  IGRdouble knots[20];			/* knots for arc		*/
  IGRdouble wghts[30];			/* weights for arc		*/
  IGRdouble h;
  IGRdouble kl,kr,rl,rr;
  IGRdouble max_tol;

  IGRlong  nbytes,nret;
  IGRlong mess;
  IGRlong bsrc;				/* BS return code		*/
  IGRlong OMmsg;			/* OM return code		*/

  IGRshort option = 0;

  IGRboolean call_bs = TRUE;

  IGRboolean boundary;

  IGRchar *ptr;				/* abstract geom pointer	*/


  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;

  GRgetabsg(msg,mat_type,matrix,&ptr,i);/* get geometry			*/

  if( 1 & *msg )
  {
    bc = (struct IGRbsp_curve *)ptr;

    if( bc->order == 2 )
    {
      if( bc->num_poles > 4 )
      {
	if( MAbcueval(&mess,bc,&option,&parms->u,pt,&h) )
	{
	  nbytes = sizeof( IGRdouble );

	  if( gr$get_chord_height_tolerance(msg = msg, sizbuf = &nbytes,
					    buffer = &max_tol, nret = &nret) )
	  {
	    arc.poles = poles;
	    arc.knots = knots;
	    arc.weights = wghts;

	    BSarcofpts(bc,pt,max_tol,&arc,&bsrc);

	    call_bs = FALSE;

	    if( bsrc == BSSUCC )
	    {
	      bc = &arc;

	      BSarccen(&bsrc,&arc,center);
	      {
		if( bsrc != BSSUCC )
		{
		  *msg = MSFAIL;
		}
	      }
	    }
	    else
	    {
	      OMmsg = om$send(msg = message GRcurve.GRcenter(msg,mat_type,
			      matrix,center),
			      targetid = my_id);
	    }
	  }
	  else
	  {
	    *msg = MSFAIL;
	  }
	}
	else
	{
	  *msg = MSFAIL;
	}
      }
      else
      {
	call_bs = FALSE;

	OMmsg = om$send(msg = message GRcurve.GRcenter(msg,mat_type,
			matrix,center),
			targetid = my_id);
      }
    }

    if( 1 & OMmsg & *msg  &&  call_bs )
    {
      BSrdcencrcv(&bsrc,bc,&parms->u,&boundary,&kl,&kr,&rl,&rr,center,pt);

      if( bsrc != BSSUCC )
      {
	*msg = MSFAIL;
      }
    }
  }

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRbspline;

