/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRvg
     METHOD NAME:	GRchghprops

     Abstract: 	Given a mask, this method adjusts the object's 
		hidden line properties by clearing or setting the
		the properties with the indicated mask.

-----
%SC%    

	GRchghprops(msg,action,mask)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *action 	  short	   indictor of whether to set or
				   	clear the properties 
				    1 - set with mask
				    0 - clear using mask
				    -1 - replace with input mask
     *mask      unsigned int  mask used to set/clear properties

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  long	 completion code message
				   MSSUCC if successful
				   MSINARG if invalid action requested
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
	
	SDG 	06/24/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method sets or clears bits in the properties word
	based on the input mask.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRchghprops(long *msg; short *action; int *mask)

{
  *msg = MSFAIL;
  return OM_W_ABORT;
}
end implementation GRvg;
