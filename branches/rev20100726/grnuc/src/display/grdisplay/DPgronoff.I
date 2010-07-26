/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPgridonoff
 
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
#include <stdio.h>
#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

method DPgridonoff (IGRlong *msg)

{

IGRlong status ;
struct DPdit_range range;

	status = OM_S_SUCCESS;
	*msg = MSSUCC;

	/* toggle the bit setting */
	ME.IGEgragad->gragad.flags ^= GRID_ON;

        /* update */

	if (!(ME.IGEgragad->gragad.flags & DP_DELAY))
	{
	   range.xlo = ME.IGEgadget->min_x_dep;
	   range.ylo = ME.IGEgadget->min_y_dep;
	   range.xhi = ME.IGEgadget->max_x_dep;
	   range.yhi = ME.IGEgadget->max_y_dep;

           status = om$send(mode = OM_e_wrt_object,
                         msg = message IGEgragad.DPgriddraw(msg,&range),
                         senderid = my_id,
                         targetid = my_id);
           if (! ( 1 & status))
           {
#ifdef DEBUG
	        om$report_error(sts = status);
	        printf("Error: in grid onoff send to IGEgragad.DPupdate\n");
#endif
           }
	}
	else
	{
	   ex$message( msgnumb = GR_I_DlyOn);
	   sleep(1);
	}

return (status);

}


method DPdelayonoff (IGRlong *msg)

{

IGRlong status ;

	status = OM_S_SUCCESS;
	*msg = MSSUCC;

	/* toggle the bit setting */
	ME.IGEgragad->gragad.flags ^= DP_DELAY;

        /* update */


return (status);
}
end implementation IGEgragad;
