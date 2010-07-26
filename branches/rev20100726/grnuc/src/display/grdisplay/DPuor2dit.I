/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgragad
	METHOD NAME:	DPuor2dit
 
     	Abstract: This method convert uor value to dit value

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *xuor	  IGRdouble
      *yuor	  IGRdouble
      *zuor	  IGRdouble
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg        IGRlong	 MSSUCC -- successful completion
      *xdit	  IGRdouble
      *ydit	  IGRdouble
      *zdit	  IGRdouble

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
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEgragad;

#include "grimport.h"

/* prototype files */
%safe
#include "maptsxfor.h"
%endsafe


method DPuor2dit (IGRlong *msg; IGRdouble *xuor; IGRdouble *yuor;
   IGRdouble *zuor; IGRdouble *xdit; IGRdouble *ydit; IGRdouble *zdit)

{

IGRlong status = OM_S_SUCCESS;
IGRdouble temp[3];
IGRlong num_points;

*msg = MSSUCC;

temp[0] = *xuor;
temp[1] = *yuor;
temp[2] = *zuor;

num_points = 1;

if(!MAptsxform(msg, &num_points, (IGRdouble *)ME.IGEgragad->gragad.wld_to_viewport,
		temp, temp))
{
	*msg = MSFAIL;
	goto wrapup;
}
*xdit = temp[0];
*ydit = temp[1];
*zdit = temp[2];

wrapup:
return (status);

}
end implementation IGEgragad;
