/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRgraphics
     METHOD NAME:	GRputname

     Abstract: This routine stores the name of the object.

-----
%SC%    
	GRputname(msg,name)

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
				    GR_E_INV_REQUEST - duplicate name
				    MSFAIL - error occurred

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
	None.
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

	This routine stores the input name in the directory.
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "DIglob.h"

method GRputname(IGRlong *msg; GRname name)
{
  	IGRlong OMmsg,
		status;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	status = di$add_name(objname = name,
			objid = my_id);

	if (status == DIR_E_NAME_DUP )
	{
	    *msg = GR_E_INV_REQUEST;
	    OMmsg = OM_E_ABORT;
	}
	else if (status != DIR_S_SUCCESS)
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);
       
	return(OMmsg);
}

end implementation GRgraphics;


