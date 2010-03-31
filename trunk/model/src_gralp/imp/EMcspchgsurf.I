/* ###################   APOGEE COMPILED   ################## */
class implementation EMScusp;

#include "EMS.h"
# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif
# include "emsdef.h"

method EMchangeSurface(IGRlong *EMmsg; GRobjid surface_id)
/*
Note: EMScusp loops have built in associativity, they don't
      need this message.

History
   
   Jack  09/25/92  Created.

*/
{
  IGRlong           sts;

  /*
   * Initialize
   */
   sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  return(sts);
}

end implementation EMScusp;
