/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline

     METHOD NAME: GRarea

     Abstract: 	This method determines the area of a closed, planar
		curve object.
		
-----
%SC%    

	GRarea(msg, mat_type, matrix, area)

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
     *area	  IGRdouble	 the area of the object

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:   none.

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
	
	KMO     02/09/87 : Design date.
	KMO	03/26/87 : Creation date.

-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "grerr.h"
#include "godef.h"
#include "gocmacros.h"

method  GRarea( IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	        IGRdouble *area )
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = GRINVMSG;
	
	

	return (OM_E_ABORT);
}

end implementation GRbspline;
