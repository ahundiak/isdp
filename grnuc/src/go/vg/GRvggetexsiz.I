/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRvg
     METHOD NAME: GRgetexsize

     Abstract: This method returns the size in bytes of the extension
	       of the internal format of the geometry of the object.

-----
%SC%    

     GRgetexsize(msg,ex_size)

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
     *msg	  IGRlong	 return code:
					MSSUCC - successful
					GRINVMSG - message was sent
				 to an object which does not respond to
				 this message.

     *ex_size      IGRlong        size of the extended geometry in bytes

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:
	     GRgetsize
-----
%RL%

     RELATIONS REFERENCED:

-----
%NB%

     NOTES:

-----
%CH%

     CHANGE HISTORY:
	
	RDH     03/26/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This method simply sends a message to the method GRgetsize.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetexsize(IGRlong *msg; IGRshort *mx_type; 
		   IGRmatrix matrix; IGRlong *ex_size)

{
  IGRlong OMmsg;

  *msg = MSSUCC;

  OMmsg = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetsize(msg,mx_type,matrix,ex_size),
                  senderid = my_id,
                  targetid = my_id);

  

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRvg;
