/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRchgcolor

     Abstract: This module changes the color of an object.

-----
%SC%    
	GRchgcolor(msg,rgb_value,color)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *rgb_value int   unsigned  new rgb value
      *color     short unsigned  new color

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   long	 completion code
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
	This module changes the color of an object.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRchgcolor(long *msg; int unsigned *rgb_value; 
		  short unsigned *color)
{
	long	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	me->display_attr.color = *color;

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

end implementation GRvg;
