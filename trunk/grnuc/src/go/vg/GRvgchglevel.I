/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRchglevel

     Abstract: This method changes the level of a graphics object.


-----
%SC%    
	GRchglevel(msg,level)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *level       IGRshort      level of the object

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
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
	
	MAS     04/02/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method changes the level of a graphics object.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRchglevel(IGRlong *msg; IGRshort *level)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	me->properties = me->properties;
	me->level = *level;

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

end implementation GRvg;

