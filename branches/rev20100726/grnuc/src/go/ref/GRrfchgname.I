/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRreffile
     METHOD NAME:	GRchgname

     Abstract: This module changes the name of a reference file attachment.

-----
%SC%    
	GRchgname ( pStatus, pModuleEnvironment, Name )

-----
%EN%
     ON ENTRY:

     NAME     			DATA TYPE  		DESCRIPTION
     ----------   		------------   		------------------------------------
      *Name	  		char			new name
      *pModuleEnvironment       struct GRmd_env 	ignored

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

#include "grerr.h"
#include "msdef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "gocmacros.h"

method GRchgname ( long *pStatus; struct GRmd_env *pModuleEnvironment; char *Name )
{
  long OMStatus, Status;
  char OldName [DI_PATH_MAX], NewName [DI_PATH_MAX];

  *pStatus = MSSUCC;
  OMStatus = OM_S_SUCCESS;

  Status = di$untranslate ( objname = OldName, objid = my_id );
  DIstmocpy ( NewName, "ref", "refnames", Name, NULL, OM_Gw_current_OS );
  Status = di$rename ( oldname = Status == DIR_S_SUCCESS ? OldName : NULL, 
      newname = NewName );
  if (Status == DIR_E_NAME_DUP)
  {
    *pStatus = GR_E_INV_REQUEST;
    OMStatus = OM_E_ABORT;
  }
  else 
    if (Status != DIR_S_SUCCESS)
    {
      *pStatus =  MSFAIL;
      OMStatus = OM_E_ABORT;
    }

  GR_NOTIFY_LISTENERS ( pStatus, &OMStatus, GR_ATTR_MODIFIED );

  return OMStatus;
}

end implementation GRreffile;

