/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline

     METHOD NAME: GRtotlength

     Abstract: 	This method determines the total arc length of
		the curve geometry.
		
-----
%SC%    

	GRtotlength(msg, mat_type, matrix, totlength)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type     IGRshort	  type of input matrix
     matrix	   IGRmatrix	  local to world transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				   - MSSUCC if successful     
				   - MSFAIL (severe) if other error
     *totlength	  IGRdouble	 the total arc length of the object

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   MAbctotlen
		GRgetabsg

     Methods:   none.

-----
%RL%

     RELATIONS REFERENCED:	None.

-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	KMO     03/27/87 : Design date.
	KMO	03/27/87 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	The method converts the object's geometry into the
	abstract form and calculates the total arc length
	by calling a math routine.

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    MAbctotlen();

method  GRtotlength( IGRlong *msg; IGRshort *mat_type;
		     IGRmatrix matrix; IGRdouble *totlength)
{

	IGRlong		status;		/*  return status 		*/
	IGRdouble	tol;		/*  tolerance for MA routine	*/
	IGRlong		sub_ints;	/*  max intervals for MA routine*/
	IGRchar		*ptr;		/*  pointer for absg geometry   */
/*
 *  initialize completion codes
 *  and internal variables
 */

	*msg = MSSUCC;
	status = OM_S_SUCCESS;

	tol = 0.0000000001;
	sub_ints = 100;

/* 
 *  generate the abstract geometry
 */

	GRgetabsg ( msg, mat_type, matrix, &ptr, i );

	
/*
 *  calculate the total arc length
 */

	if (! MAbctotlen ( msg, ptr, &tol, &sub_ints, totlength ))
	{
	    *msg = MSFAIL;
	    status = OM_E_ABORT;
	}

	

	return (status);
}

end implementation GRbspline;
