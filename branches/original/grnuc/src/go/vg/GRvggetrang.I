/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRgetrang

     Abstract: This routine retrieves the range of the object.

-----
%SC%    
	GRgetrang(msg,matrix_type,matrix,world,range)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	 type of environment matrix
     matrix	   IGRmatrix	 environment matrix
     *world	   IGRboolean    indicator of whether the range should
			 	 be computed in world or local coordinates
				  1 : apply the environment matrix
				  0 : do not apply the environment matrix
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
      range	   GRrange	 range of the object
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	none.

     Methods:
	none.
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This routine retrieves the range of the object and
	stores it in the input array.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetrang(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRboolean *world; GRrange range)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	range[0] = range[1] = range[2] = GRDGNLIMITS_MIN_D;
	range[3] = range[4] = range[5] = GRDGNLIMITS_MAX_D;

	

	return(OM_S_SUCCESS);

}

end implementation GRvg;

