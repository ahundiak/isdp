/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPgriddraw
 
     	Abstract: This method draws grid if grid_on 

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

	HT  04/28/86  : Creation date.
--
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "igewindef.h"
#include "igewinmacros.h"

/* prototype files */
%safe
#include "dpgrid.h"
#include "dpconstgrid.h"
%endsafe

method DPgriddraw (IGRlong *msg;struct DPdit_range *range)

    {

	IGRlong status = OM_S_SUCCESS;

	*msg = MSSUCC;

	if ( !(ME.IGEgragad->gragad.flags & IS_ACTIVE))
	{
	   goto wrapup;        /* window not active, exit */
	}

	/* +/- 3 to the range to make sure if any part of the 
	   grid was in range the center will be now and therefore
	   will be redrawn */
        range->xlo -= 3;
        range->ylo -= 3;
        range->xhi += 3;
        range->yhi += 3;
        if (range->xlo < ME.IGEgragad->gragad.dit_clip_range[0])
        	range->xlo = ME.IGEgragad->gragad.dit_clip_range[0];
        if (range->ylo < ME.IGEgragad->gragad.dit_clip_range[1])
        	range->ylo = ME.IGEgragad->gragad.dit_clip_range[1];
        if (range->xhi > ME.IGEgragad->gragad.dit_clip_range[3])
        	range->xhi = ME.IGEgragad->gragad.dit_clip_range[3];
        if (range->yhi > ME.IGEgragad->gragad.dit_clip_range[4])
        	range->yhi = ME.IGEgragad->gragad.dit_clip_range[4];


	if (ME.IGEgragad->gragad.flags & VALID_ALT_INV)
   	{
	   status = DPconstgrid(msg,&ME.IGEgragad->gragad,
	   	ME.IGEgadget->win_no, range->xlo,
		range->ylo,range->xhi,range->yhi);
	}
	else
	{
	   status = DPgrid(msg,&ME.IGEgragad->gragad,
			ME.IGEgadget->win_no, range->xlo,
			range->ylo,range->xhi,range->yhi);
	 
	
	}

wrapup:

return (status);

}  /* DPgriddraw */
end implementation IGEgragad;
