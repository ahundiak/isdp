/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline

     METHOD NAME:	GRinplane

     Abstract: 	This method determines the relationship between a
		B-spline curve and a plane.  This relationship
		indicates whether or not the curve lies in the 
		plane.
	
-----
%SC%    

     GRinplane(msg,matrix_type,matrix,plane,tolerance,rel)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *plane	   IGRplane	  input plane 
     *tolerance	   IGRdouble	  accuracy required to determine if 
				  the B-spline lies in the plane
				  (allowable distance from plane)

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *rel	   IGRshort	 value representing the relation
				 between the B-spline and plane--
				    +1 - curve in plane
				    -1 - curve not in plane

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:	
		MAbcinpl

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
	
	SDG     05/12/86 : Design date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method utilizes a math function (MAbcinpl) that will 
	determine the relationship between the B-spline curve and 
	plane.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbcinpl();

method GRinplane(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
		struct IGRplane *plane; IGRdouble *tolerance; 
		IGRshort *rel)
{
	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local return code		*/
	IGRchar *absgptr;		/* abstract geometry pointer	*/
	struct IGRbsp_curve *curve;	/* pointer to B-spline curve	*/

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	
	GRgetabsg(&msg1,matrix_type,matrix,&absgptr,i);

	if (! (1 & msg1))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
	}

	curve = (struct IGRbsp_curve *)absgptr;

	if (! (1 & MAbcinpl(&msg1,curve,plane,tolerance,rel)))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;	
	}

	

wrapup:
	
	return(OMmsg);

}

end implementation GRbspline;
