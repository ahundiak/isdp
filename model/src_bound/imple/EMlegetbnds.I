/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlinedge;

#include "EMS.h"
method EMgetbounds(IGRlong *EMmsg;struct EMSedgebound *bound)
{
  *EMmsg = EMS_S_Success;

  if(ME.EMSedge->ed_props & EMED_REVERSED)
   {
     bound[0].span_inx = ME.EMSlinedge->num_points - 2;
     bound[0].param = 1.0;
     bound[1].span_inx = 0;
     bound[1].param = 0.0;
   }
  else
   {
     bound[1].span_inx = ME.EMSlinedge->num_points - 2;
     bound[1].param = 1.0;
     bound[0].span_inx = 0;
     bound[0].param = 0.0;
   }
  return(OM_S_SUCCESS);
}
end implementation EMSlinedge;
