/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg

     METHOD NAME:	GRputsymb

     Abstract: This method defines the symbology
	       of the object.
-----
%SC%    
     GRputsymb(msg,symb)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *symb        GRsymbology	  symbology internal format

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

     Modules:	none.

     Methods:	none.
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method initializes the symbology pointer in the
	instance data of the object.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "dpdef.h"

method GRputsymb(IGRlong *msg; struct GRsymbology *symb)
{
	IGRlong	OMmsg;


	if ((symb->level < 0 ) || (symb->level >= DP_NUM_OF_LEVELS))
	{
	    OMmsg = OM_E_ABORT;
	    *msg = MSFAIL;
	}
	else
	{
	    OMmsg = OM_S_SUCCESS;
	    *msg = MSSUCC;
	    me->display_attr = symb->display_attr;
	    me->level = symb->level;

	    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);
	}

	return(OMmsg);
}

end implementation GRvg;

