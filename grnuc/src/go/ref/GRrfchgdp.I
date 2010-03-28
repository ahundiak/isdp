/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRreffile
     METHOD NAME:	GRchgdp

     Abstract: 	This method changes the display attributes of 
		a graphics object.

-----
%SC%    
	GRchgdp(msg,dp_attr)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *dp_attr      IGRdisplay    display attributes

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
        WBC     10/07/92 : Just setting the bit for GROVERRIDE_SYMBOLOGY in
                           the reference file properties instead of assigning
                           GROVERRIDE_SYMBOLOGY as the reference file
                           properties.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method assigns new display attributes to a graphics
object.
----*/
/*EH*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "refdef.h"

method GRchgdp(IGRlong *msg; struct IGRdisplay *dp_attr)
{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;
	*msg = MSSUCC;

	me->ref_properties |= GROVERRIDE_SYMBOLOGY;
 
	me->display_attr = *dp_attr;

	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_ATTR_MODIFIED);

	return(OM_S_SUCCESS);
}

end implementation GRreffile;

