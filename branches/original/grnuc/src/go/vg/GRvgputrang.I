/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg

     METHOD NAME:	GRputrang

     Abstract: This method stores the range of the object.
-----
%SC%    
	GRputrang(msg,range)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      range        GRrange	  range of object

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
	
	MAS     03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This routine stores the range of the object.
----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"

method GRputrang(IGRlong *msg; GRrange range)
{
	
	*msg = MSSUCC;

	return(OM_S_SUCCESS);
}

end implementation GRvg;

