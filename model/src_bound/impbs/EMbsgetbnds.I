/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
method EMgetbounds(IGRlong *EMmsg;struct EMSedgebound *bound)
{
  *EMmsg = EMS_S_Success;

  if(ME.EMSedge->ed_props & EMED_REVERSED)
   {
     bound[0].span_inx = 0;
     bound[0].param = 1.0;
     bound[1].span_inx = 0;
     bound[1].param = 0.0;
   }
  else
   {
     bound[0].span_inx = 0;
     bound[0].param = 0.0;
     bound[1].span_inx = 0;
     bound[1].param = 1.0;
   }
  return(OM_S_SUCCESS);
}
end implementation EMSbsedge;
