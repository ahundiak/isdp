/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPinrot
 
     	Abstract: This method returns the rotation matrix
		  for the particular view.

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

     rotate	 IGRdouble[16]   contains the rotation matrix that
				 is inquired from the window structure

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


method DPinrot (IGRlong *msg; IGRdouble *rotate)

{

IGRlong status = OM_S_SUCCESS;
IGRdouble temp[4][4];

*msg = MSSUCC;

if (ME.IGEgragad->gragad.flags & VALID_ALT_INV)
{
    OM_BLOCK_MOVE( ME.IGEgragad->gragad.construct_plane,
                   temp,
                   (sizeof(IGRdouble)*16));
		    temp[0][3] = 0;
		    temp[1][3] = 0;
		    temp[2][3] = 0;
   OM_BLOCK_MOVE( temp,
                  rotate,
                 (sizeof(IGRdouble)*16));
}
else
{
   OM_BLOCK_MOVE( ME.IGEgragad->gragad.rotation,
                  rotate,
                  (sizeof(IGRdouble)*16));
}
return (status);

}
end implementation IGEgragad;
