/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRgraphics

     METHOD NAME:  GRundocp

     Abstract:  This method restores (undo copy) an object
		that has been saved (copied for undo).

----
%SC%    

     GRundocp ( msg, md_env, delete )

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	 struct GRmd_env  environment info for the object
     *delete	 IGRboolean	  flag indicating what operation
				  had been performed on the object
				  0 - not delete
				  1 - delete

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  GRaddwrng
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
	
	KMO     02/11/87 : Design date.
	KMO 	02/11/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	All necessary operations are performed on an object
	to restore it in the specified object space.  Currently,
	the only operation required is to add the object to
	the R-tree.	
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"

method GRundocp(IGRlong *msg; struct GRmd_env *env;
	         IGRboolean *delete)
{
	IGRlong		status;		/* OM return status */
	
/*
 *  initialize completion codes
 */

	*msg = MSSUCC;
	status = OM_S_SUCCESS;

/*
 *  restore the object
 */

	status = om$send ( mode = OM_e_wrt_object,
			   msg = message GRgraphics.GRaddwrng ( msg, env ),
			   senderid = my_id,
			   targetid = my_id );

    return(status);
}

end implementation GRgraphics;
