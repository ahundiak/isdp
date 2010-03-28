/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GR3dellipse	
     METHOD NAME:   GRclipto

     Abstract: 
		This method returns the class name of the object
	that a 3-D ellipse clips to.

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
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method returns the class name of GR3dellarc, which is
	what this object clips to.
----*/
/*EH*/

class implementation GR3dellipse;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRclipto(IGRlong *msg; IGRchar *classname)

{
	IGRlong	OMmsg;

	OMmsg = OM_S_SUCCESS;		/* initialize to success	*/
	*msg = MSSUCC;			/* initialize to success	*/

 	strcpy(classname,"GR3dellarc"); /* clipto classname		*/

	

	return (OM_S_SUCCESS);

}

end implementation GR3dellipse;
