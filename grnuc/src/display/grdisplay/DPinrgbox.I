/*-----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPinrgbox
 
     	Abstract: This method returns the world to viewport matrix,
		  viewport to world matrix,and tolerance in world 
		  coordinate units for the particular view.

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

     wld_vwpt	 IGRdouble[16]   contains the world to viewport matrix that
				 is inquired from the view structure

     vwpt_wld	 IGRdouble[16]   contains the viewport to world matrix that
				 is inquired from the view structure

     wcs_tol	 IGRdouble	 contains the tolerance in world
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
#include "OMmacros.h"


method DPinrgbox (IGRlong *msg; IGRdouble *wld_vwpt; IGRdouble
*vwpt_wld; IGRdouble *wcs_tol)
{

IGRlong status = OM_S_SUCCESS;

*msg = MSSUCC;
OM_BLOCK_MOVE( ME.IGEgragad->gragad.wld_to_viewport,
               wld_vwpt,
               (sizeof(IGRdouble)*16));
    
OM_BLOCK_MOVE( ME.IGEgragad->gragad.viewport_to_wld,
               vwpt_wld,
              (sizeof(IGRdouble)*16));
   
*wcs_tol = ME.IGEgragad->gragad.dit_tol / ME.IGEgragad->gragad.vvol_viewport_scale;

return (status);
}

end implementation IGEgragad;
