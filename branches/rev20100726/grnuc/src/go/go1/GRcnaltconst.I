/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRconic
     METHOD NAMES: GRaltconstruct

     Abstract: This file contains the alternate construct method 
		the conic classes.
-----
%SC%    

    VALUE = GRaltconstruct(arglist)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *arglist     GRvg_construct construct arguments

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

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
	   The return code in the input argument list can have the 
	  following values:
     	  
		MSSUCC - successful
	        MSFAIL - if failure
	    	GRSNOINVTRAN - if input matrix is not invertible
	        GRSDGNEXCEED - if range exceeds design limits

	   If the newflag argument is FALSE, this routine simply
	  exits giving the caller a template of the object.

-----
%CH%

     CHANGE HISTORY:

	MAS	10/08/97 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine fills in the instance data of the object being 
constructed and posts the object.

This method expects the input geometry to be an IGRarc structure.

----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"

method GRaltconstruct(struct GRvg_construct *arglist)
{
    IGRlong 	OMmsg;
    IGRshort	type;

    OMmsg = OM_S_SUCCESS;
    *(arglist->msg) = MSSUCC;

    if( ! arglist->newflag )
    {
        me->display_attr =  *(arglist->display);
        me->level = arglist->level;

	type = GRCN;
	OMmsg = GRconsfunction(arglist,&my_id,&me->properties, 0, &type );
    }
  return( OMmsg );
}
end implementation GRconic;
