class implementation SKhvptpt;

#include "OMmacros.h"

#define X 0
#define Y 1

from SKvariable import SKgetvar;

method SKorder_points(IGRlong *EMmsg; IGRushort options;
                       IGRint num_pts; GRobjid *pt_ids;
                       IGRchar *moreinfo)
{
 OM_S_OBJID pt_ids_buff[2];
 IGRpoint pt1, pt2;
 IGRlong inx, status;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 if (num_pts != 2)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }
 
 OM_BLOCK_MOVE (pt_ids, pt_ids_buff, sizeof (OM_S_OBJID) * num_pts);

 status = om$send (msg = message SKvariable.SKgetvar (EMmsg, NULL, 
                       NULL, NULL, pt1),
                   targetid = pt_ids_buff[0]);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 status = om$send (msg = message SKvariable.SKgetvar (EMmsg, NULL, NULL, 
                       NULL, pt2),
                   targetid = pt_ids_buff[1]);
 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 inx = ME.SKconstraint->props & SK_HORIZONTAL ? X : Y;
 if (pt1[inx] > pt2[inx])
 {
   pt_ids[0] = pt_ids_buff[1];
   pt_ids[1] = pt_ids_buff[0];
 }


wrapup:
 EMWRAPUP (*EMmsg, status, "SKhvptpt.SKorder_points");
 return (status);
}
end implementation SKhvptpt;
