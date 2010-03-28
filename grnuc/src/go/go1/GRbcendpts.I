/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAME: GRendpts

     Abstract: This routine determines the endpoints
	       (beginning and ending points) of the
	       graphics object.
-----
%SC%    

     GRendpts(msg,mat_type,matrix,startpt,endpt)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred

     startpt	  IGRpoint	 start point
     endpt	  IGRpoint	 end poiint

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	     MAbcendpts
	     
     Methods:
	     
-----
%RL%

     RELATIONS REFERENCED:
			  
-----
%NB%

     NOTES:
	   
-----
%CH%

     CHANGE HISTORY:
	
	RDH     04/14/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method gets the abstract geometry of the object and calls
MAbcendpts to get the endpoints of the curve.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcendpts();

method GRendpts(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 IGRpoint startpt,endpt)
{
  struct IGRbsp_curve *bc;		/* abstract geometry pointer  */

  IGRchar *ptr;				/* abstract geometry pointer  */

  IGRlong OMmsg;			/* OM return code	      */



  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;	

  GRgetabsg(msg,mat_type,matrix,&ptr,i); /* get abstract geometry      */

  if( 1 & *msg )
    {
      bc = (struct IGRbsp_curve *)ptr;

      MAbcendpts(msg,bc,startpt,endpt);	/* get curve end points	      */
    }

	

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRbspline;
