/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRbcsubbc	
     METHOD NAME:   GRclipto

     Abstract: 
		This method returns the class name of the object
	that a 3-D, B-spline subcurve clips to.

-----
%SC%    

     GRclipto(msg,classname)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC always successful
     *classname   IGRchar	 array for classname

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:			None.

     Methods:		
				None.

-----
%RL%

     RELATIONS REFERENCED:	None.
-----
%NB%

     NOTES:			None.
-----
%CH%

     CHANGE HISTORY:
	
	MAS	05/9/86 : Creation date.
    dhm 02/22/88 : Added GR_NOTIFY_LISTENERS
    dhm 06/09/88 : Took out GR_INQUIRED notification.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method returns the class name of GRbcsubbc, which is
	what this object clips to.
----*/
/*EH*/

class implementation GRbcsubbc;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif
# include "godef.h"
# include "gocmacros.h"

/*#include "grdef.h"*/
/*#include "gopriv.h"*/

method GRclipto(IGRlong *msg; IGRchar *classname)
{
    IGRlong  sts;

    sts = OM_S_SUCCESS;
	*msg = MSSUCC;			/* initialize to success	*/

 	strcpy(classname,"GRbcsubbc"); /* clipto classname		*/


	return (sts);

}

end implementation GRbcsubbc;
