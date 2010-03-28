/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic

     METHOD NAME: GRarea

     Abstract: 	This method determines the area of a closed
		conic object.
		
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

     Modules:   MAelarea

     Methods:   GRgetarc

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

	This method initializes the IGRarc structure
 	and calculates the area of the object.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "madef.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method  GRarea( IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	        IGRdouble *area )
{
	IGRlong		status;		/*  OM return status		*/
	struct IGRarc	ellipse;	/*  internal arc structure	*/

/*
 *  initialize completion codes
 */

	*msg = MSSUCC;
	status = OM_S_SUCCESS;

/*
 *  initialize the IGRarc structure
 */

	status = om$send (mode = OM_e_wrt_object,
			  msg = message GRconic.GRgetarc ( msg, mat_type,
				        matrix, &ellipse ),
			  senderid = my_id,
			  targetid = my_id );

/*
 *  if the object is an ellipse or circle, calculate the area
 */

	if ( (1 & status) && (ellipse.sweep_angle == (2 * PI)) )
	{
	    status = MAelarea ( msg, &ellipse, area );
	}
	else
	{
	    status = OM_E_ABORT;
	    *msg = MSFAIL;
	}

	

	return (status);

}
end implementation GRconic;
