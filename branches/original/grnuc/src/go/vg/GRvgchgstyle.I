/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRchgstyle

     Abstract: 	This method changes the style of a graphics object.


-----
%SC%    
	GRchgstyle(msg,style)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *style     char unsigned  new style

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
	This method changes the style of a graphics object.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRchgstyle(long *msg;  char unsigned *style)
{
	long	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	me->display_attr.style = *style;

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

end implementation GRvg;

