/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRbspline
     METHOD NAMES: GRconstruct

     Abstract: This file contains the construct method for the B-spline
              based subclasses of the GRbspline class.

-----
%SC%    

    VALUE = GRconstruct(arglist)

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

	RDH,SDG 01/13/86 : Design date.
	MAS	09/22/86 : Upgrade to 40.
	MAS	10/08/87 : Redesigned to call function
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine fills in the instance data of the object being 
constructed and posts the object.
----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"

method GRconstruct(struct GRvg_construct *arglist)
{
    IGRlong	OMmsg;
    IGRshort	type;

    OMmsg = OM_S_SUCCESS;
    *(arglist->msg) = MSSUCC;


    if( !arglist->newflag )
    {
        me->display_attr =  *(arglist->display);
        me->level = arglist->level;

	type = GRCURVE;
	OMmsg = GRconsfunction(arglist,&my_id,&me->properties, 0, &type);
    }

  return( OMmsg );
}
end implementation GRbspline;
