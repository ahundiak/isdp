/* 
   DESCRIPTION
  
   This routine reports information about the object.

   RETURN VALUES
   
   msg	  	 	completion code
  			- MSSUCC  if successfull
  			- MSFAIL (severe) if failure
   info			return object information

   NOTES

   For now, the method simply returns the type of the 
   object in the GRobj_info structure.
  
   HISTORY
  
   07/20/86 : SDG : Design date.
   04/05/87 : rlw : Changed to method of GRsubbc
   02/22/88 : dhm : Added GR_NOTIFY_LISTENERS
   06/09/88 : dhm : Took out GR_INQUIRED notification.
 */

class implementation GRsubbc;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC */
#include "godef.h"
#include "gocmacros.h"
#include "ECmsg.h"
#include "msmacros.h"

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
  *msg = MSSUCC;
  ex$message ( buff = info->type, msgnumb = EMS_S_BsplineCurve );
  return OM_S_SUCCESS;
}

end implementation GRsubbc;


