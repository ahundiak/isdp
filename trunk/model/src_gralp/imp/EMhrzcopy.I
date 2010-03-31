/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
class implementation EMShorizon;

#include "EMS.h"
#include "igrtypedef.h"
#include "igetypedef.h"


/* history
   30-Oct-91  jack  created

   notes
      Just return success.  We don't want to support copy of 
      horizon edges and they won't show up during move.        
*/   

method EMhelperCopy( IGRlong          *EMmsg; 
                     struct GRid      *sender_copy;
                     struct EMcp_info *copy_info )
{
  IGRlong             sts;
 
  /*
   * Initialize
   */
   sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

   return( sts );                              
}

end implementation EMShorizon;
