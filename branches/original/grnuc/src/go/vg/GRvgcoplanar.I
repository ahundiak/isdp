/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRvg
     METHOD NAME:   GRcoplanar

     Abstract: 
		This method determines if a set of
		elements lie on a unique plane.
	
-----
%SC%    

     GRcoplanar(msg,matrix_type,matrix,num_objects,
		obj_ids,tolerance,plane)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	 type of transformation matrix
     matrix	   IGRmatrix	 transformation matrix
     *num_objects  IGRshort 	 number of elements
     *obj_ids      GRobjid	 array of object ids 
     *tolerance    IGRdouble 	 tolerance needed for calculations
     *plane	   IGRplane	 plane to contain elements
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:			

     Methods:			

-----
%RL%

     RELATIONS REFERENCED:	None.
-----
%NB%

     NOTES:			None.
-----
%CH%

     CHANGE HISTORY:
	
	KMO     03/27/86 : Design date.
	KMO     03/27/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method determines if a set of elements are coplanar.


----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRcoplanar(IGRlong *msg; IGRshort *matrix_type;
		  IGRmatrix matrix; IGRshort *num_objects;
		  GRobjid *obj_ids; IGRdouble *tolerance;
	          struct IGRplane *plane)
{
	IGRlong 	value;		/* return value */

	value = OM_S_SUCCESS;
	*msg = MSSUCC;

	return (value);
}

end implementation GRvg;
