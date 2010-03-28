/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAME: GRcenter

     Abstract: This routine calculates the origin of a conic
	       element.

-----
%SC%    

     GRcenter(msg,mat_type,matrix,center)

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
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     center	  IGRpoint	 origin of conic element
     
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	     GRgenabsg

     Methods:
	     MAbcelprops

-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:
	   The conic element is expected to be non-degenerate.

-----
%CH%

     CHANGE HISTORY:
	
	RDH     04/08/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This routine gets the abstract geometry of the element
	and sends the B-spline curve to MAbcelprops to find the
	center of the conic element.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bserr.h"

method GRcenter(IGRlong *msg; IGRshort *mat_type; 
		IGRmatrix matrix; IGRpoint center)

{
  struct IGRbsp_curve *bc;		/* pointer to abstract geom   */

  IGRchar *ptr;				/* pointer to abstract geom   */

  IGRlong OMmsg;			/* OM return code	      */
  IGRlong mess;

  *msg = MSSUCC;
  OMmsg = OM_S_SUCCESS;


  GRgetabsg(msg,mat_type,matrix,&ptr,i);/* get abstract geometry      */

  if( *msg & 1 )
  {
    bc = (struct IGRbsp_curve *)ptr;

    BSarccen(&mess,bc,center);

    if( mess != BSSUCC )
    {
      *msg = MSFAIL;
    }
  }
  else
  {
    OMmsg = OM_E_ABORT;
  }


  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRconic;
