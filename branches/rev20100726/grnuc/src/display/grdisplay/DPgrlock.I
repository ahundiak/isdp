/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPgridlock
 
     	Abstract: This method toggles the grid_on bit setting in view
		  instance data

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg           IGRlong	 MSSUCC -- successful completion

-----
%RL%

	RELATIONS REFERENCED:

-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

	HT 04/07/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEgragad;

#include "grimport.h"

method DPgridlock (IGRlong *msg)

{

IGRlong status ;

status = OM_S_SUCCESS;
*msg = MSSUCC;

/* toggle the bit setting */
ME.IGEgragad->gragad.flags ^= GRID_LOCK;

return (status);

}
end implementation IGEgragad;
