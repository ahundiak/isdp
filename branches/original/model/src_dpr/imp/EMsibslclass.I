/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfimpbnd;

#include "EMS.h"
/*
Description
    This method returns its corresponding solid class.

History 
    DLB 06/14/88 Creation.
*/

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_E_InvalidCase;
  return(OM_S_SUCCESS);
}
end implementation EMSsfimpbnd;
