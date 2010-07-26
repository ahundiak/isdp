/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRgraphics
     METHOD NAME:	GRgetname

     Abstract: This routine retrieves the name of the object.

-----
%SC%    
	GRgetname(msg,name)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
				    MSFAIL - object not named
      name	   GRname	 name of the object
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
		If the object is not named, a null character will
		be returned in the first position of the input
		name array.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     03/27/86 : Design date.
	AIC	07/04/91 : Moved from GRvg to GRgraphics.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This routine retrieves the name of the object and
	stores it in the input array.

----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"

method GRgetname(IGRlong *msg; GRname name)
{
	IGRlong	OMmsg,
		status;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	status = di$untranslate(objname = name,
		objid = my_id);

	if (status != DIR_S_SUCCESS)
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    name[0] = '\0';
	}

	

	return(OMmsg);
}

end implementation GRgraphics;


