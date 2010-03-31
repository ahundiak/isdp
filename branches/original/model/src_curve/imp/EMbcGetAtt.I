/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbcsubbc

     METHOD NAME:	GRgetattr

     Abstract: 	This method gets the element specific attributes of
		the object.

-----
%SC%    

    GRgetattr(msg,attr)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
       *attr	   IGRchar	  char pointer to attributes

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
       *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure


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
	
	SDG     06/24/86 : Creation date.
    dhm     02/22/88 : Added GR_NOTIFY_LISTENERS
    dhm     06/09/88 : Took out GR_INQUIRED notification.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method gets the element specific attributes of the 
	object.

----*/
/*EH*/

class implementation GRbcsubbc;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "igrdef.h"
/*#include "grdef.h"*/
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetattr(IGRlong *msg; IGRchar *attr)

{

	IGRlong OMmsg;
	struct IGResbc *bc_attr;

	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;

	bc_attr = (struct IGResbc *)attr;

	bc_attr->is_polydis = ME.GRbcsubbc->dp_props & GRIS_POLYDIS;
	bc_attr->is_curvedis = ME.GRbcsubbc->dp_props & GRIS_CURVEDIS;


	return(OMmsg);

}

end implementation GRbcsubbc;
