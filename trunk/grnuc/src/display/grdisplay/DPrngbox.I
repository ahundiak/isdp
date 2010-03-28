/*-----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPrngbox
 
     	Abstract: This method returns a range box in world coordinates
		  for a WCS point.

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

     wcs_pnt	   IGRpoint[1]   a point in world coordinate system 

     dit_tol	  *IGRdouble      dit tolerance

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg           IGRlong	 MSSUCC -- successful completion

     range	  GRrange	 contains the tolerance in world
				 coordinate units	
-----
%RL%

	RELATIONS REFERENCED:

-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

	MP  1/13/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEgragad;

#include "grimport.h"

method DPrngbox (IGRlong *msg; IGRdouble *x; IGRdouble *y; IGRdouble *z;
			 IGRdouble *dit_tol;IGRdouble *range)
{
IGRdouble wcs_tol;

 
IGRlong status = OM_S_SUCCESS;

*msg = MSSUCC;
   
wcs_tol = *dit_tol / ME.IGEgragad->gragad.vvol_viewport_scale;

range[0] = *x - wcs_tol;
range[1] = *y - wcs_tol;
range[2] = *z - wcs_tol;

range[3] = *x + wcs_tol;
range[4] = *y + wcs_tol;
range[5] = *z + wcs_tol;

return (status);
}

end implementation IGEgragad;
