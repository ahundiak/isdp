/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRreffile
     METHOD NAME:	GRputname

     Abstract: This module puts the name of a reference file attachment.

-----
%SC%    
	GRputname ( pStatus, Name )

-----
%EN%
     ON ENTRY:

     NAME     			DATA TYPE  		DESCRIPTION
     ----------   		------------   		------------------------------------
      *Name	  		char			new name

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *pStatus	   long	         completion code
				    MSSUCC - successful completion
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
        di$macros
	none.

     Methods:
	none.
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:
	
	HGB     12/16/92: Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This module changes the name of a reference file attachment 
	(not the mount name!).

----*/
/*EH*/

class implementation GRreffile;

#include "msdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "gocmacros.h"

method GRputname ( long *pStatus; char *Name )
{
  /*
   * It is safe to call GRchgname because attachments can have only one name.
   */
  return om$send ( msg = message GRgraphics.GRchgname ( pStatus, NULL, Name ),
      targetid = my_id );
}

end implementation GRreffile;


