/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRreffile
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
      *rgb_value IGRint   unsigned  new rgb value
      *color     IGRshort unsigned  new color

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
        dhm     07/06/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This module changes the color of an object.

----*/
/*EH*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "refdef.h"

method GRchgcolor(IGRlong *msg; IGRuint *rgb_value; 
		  IGRushort *color)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	if (me->ref_properties & GROVERRIDE_SYMBOLOGY)
          me->display_attr.color = *color;
	else
	{
	    me->ref_properties |= GROVERRIDE_SYMBOLOGY;

	    me->display_attr.color = *color;
	    me->display_attr.weight = (IGRuchar) ~0;
	    me->display_attr.style  = (IGRuchar) ~0;

	}

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

end implementation GRreffile;
