/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:       GRtext
     METHOD NAME:       GRgetobjinfo

     Abstract: This routine reports information about the object.

-----
%SC%    
        GRgetobjinfo(msg,info)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   ------------------------------------
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg        IGRlong        completion code
                                    MSSUCC - successful completion
      *info       GRobj_info     structure for information about 
                                 the object
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
                none.

     Methods:
                none.
-----
%NB%

     NOTES:
                none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC    11/05/86 : Design date.
        SCW    07/22/92 : Removed copyright header
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine retrieves information about the object and stores
it in the input structure.
----*/
/*EH*/

class implementation GRtext;

#include   "godef.h"
#include   "gocmacros.h"
#include   "msdef.h"
#include   "grmessage.h"
#include   "msmacros.h"
#include   "grimport.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
   IGRlong OMmsg;

   OMmsg = OM_S_SUCCESS;
   *msg = MSSUCC;

   ex$message(msgnumb = GR_I_text,
              buff = info->type);

   return(OM_S_SUCCESS);
}

end implementation GRtext;
