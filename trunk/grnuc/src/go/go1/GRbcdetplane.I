/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline

     METHOD NAME:	GRdetplane

     Abstract: 	This method determines a plane from a graphics
		object.
	
-----
%SC%    

     GRdetplane(msg,matrix_type,matrix,plane)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MASDGENRAT if all points are
				      collinear
				    - MANONPLANAR if plane cannot be
				      found which contains all pts
				    - MSFAIL (severe) if failure
     *plane	   IGRplane	  plane 

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAdetplane

     Methods:	

		GRgenabsg		
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method utilizes a math function (MAdetplane) that will 
	determine the plane.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "mapriv.h"
#include "godef.h"
#include "gocmacros.h"
#include "bsparameters.h"
#include "bserr.h"

extern    IGRboolean    MAdetplane();

method GRdetplane(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		  struct IGRplane *plane)
{
	struct IGRbsp_curve *curve;	/* pointer to B-spline curve	*/

	IGRdouble tol;			/* planarity tolerance		*/

        IGRboolean b_status;

	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/
	IGRlong bsrc;

	IGRint  name;

	IGRchar *absgptr;		/* abstract geometry pointer	*/


	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	name = BSTOLLENVEC;

	BSxtractpar(&bsrc,name,&tol);

        if( bsrc == BSSUCC )
	{
	  GRgetabsg(&msg1,matrix_type,matrix,&absgptr,i);

	  if (! (1 & msg1))
	  {
	     *msg = MSFAIL;
	     OMmsg = OM_E_ABORT;
	     goto wrapup;
	  }

	  curve = (struct IGRbsp_curve *)absgptr;

	  b_status = MAbcunweight(msg,curve);

	  MAdetplane(msg,&curve->poles[0],&curve->num_poles,&tol,plane);

	  b_status = MAbcweight(&msg1,curve);
	}
	else
	{
	  *msg = MSFAIL;
	}

	

wrapup:

	return(OMmsg);

}

end implementation GRbspline;
