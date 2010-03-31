/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
method EMtree_display(IGRlong *EMmsg; IGRshort *type; IGRmatrix matrix;
                      enum GRdpmode *mode; struct GRid *display_info;
                      GRobjid *stop_ids; IGRint stop_count)
/*
 Abstract
    This method displays the surface if it is not in the stop_ids list.

 Return Status
    EMmsg - EMS_S_Success if all is well

 Notes
    Initial user of this method is dpr selective undo.

 History
    DLB 04/04/88 Creation.
*/
{
 IGRlong OM_stat = OM_S_SUCCESS;
 IGRint i;


 *EMmsg = EMS_S_Success;

 for(i=0; i<stop_count; i++)
   if (my_id == stop_ids[i]) break;

 if (i == stop_count) 
 {
   /*Didn't get a hit.*/
   OM_S_CHANSELECT to_comps;

   to_comps.type = OM_e_addr;
   to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

   OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_comps);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 }

 wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMScompsurf.EMtree_display")
  return(OM_stat);
}

end implementation EMScompsurf;
