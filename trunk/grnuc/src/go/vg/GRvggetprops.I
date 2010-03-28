/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRgetprops

     Abstract: 	This method returns to the caller the object's 
		properties word.

-----
%SC%    

	GRgetprops(msg,props)

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
     *msg	  IGRlong	 completion code message
				   MSSUCC if successful
     *props       IGRshort  	 object's properties word
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	SDG 	09/10/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method retrieves an object's properties word.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"

method GRgetprops(IGRlong *msg;  IGRshort *props)

{
	*msg = MSSUCC;

	*props = me->properties;

	return(OM_S_SUCCESS);
}
end implementation GRvg;
