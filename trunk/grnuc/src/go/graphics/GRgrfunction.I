/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRgraphics

     METHOD NAME:  GRfunction

     Abstract:  This method invokes a user provided function
		using the information passed into the method
		in the usr_info argument.
	
-----
%SC%    

    GRfunction ( msg, usr_function, usr_info )

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *usr_function()  IGRint	 
     *usr_info        IGRchar

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *usr_info    IGRchar
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none

     Methods:  none

-----
%RL%

     RELATIONS REFERENCED:  none
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	MAS     01/28/87 : Design date.
	MAS	01/28/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This function invokes the user supplied function as
	follows:

    	(*user_function)(msg,&my_info,user_info);

	my_info is of type GRid and contains the object id and
	space number of the object.  

	Additional information may be passed to the function
	in user_info. Although the user_info is typed as a
	character pointer it is actually a pointer to 
	a GRfunction_info structure.  This structure can
	be loaded using a the macro go$buildbuf.
		
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"

method GRfunction(IGRlong *msg; IGRint (*user_function)();
		  IGRchar *user_info)
{
    IGRlong   	OMmsg;			/* om return code		*/
    struct GRid	my_info;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    my_info.objid = my_id;
    my_info.osnum = OM_Gw_current_OS;

    OMmsg = (*user_function)(msg,&my_info,user_info);

    if (! (1 & *msg))
    {
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}

end implementation GRgraphics;
