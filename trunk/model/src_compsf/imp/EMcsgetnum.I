/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "msdef.h"

method GRget_number_components(IGRlong *msg; IGRint *count)

/*
Description
     This method totals all leaf components.

Notes 
     Components that are also composites will not be added to the count.

Return Values
     msg - MSSUCC if all is well.
     count - current number of leaf components

History
     DLB 10/28/87 Creation.
*/
{
 IGRlong         OM_stat;
 OMuint          comp_count;
 IGRint          my_count, i;
 OM_S_CHANSELECT to_comps;


 OM_stat = OM_S_SUCCESS;
 *msg = MSSUCC;

 *count = 0;
 my_count = 0;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 OM_stat = om$get_channel_count(object = me, 
                                p_chanselect = &to_comps,
                                count = &comp_count);
 if (!(1 & OM_stat)) goto wrapup;

 for (i = 0; i < comp_count; i ++)
 {
   /*Send on to comp*/
   OM_stat = om$send(msg = message GRowner.GRget_number_components(msg, 
                           &my_count), 
                           p_chanselect = &to_comps,
                           from = i, to = i);
   if (!(1 & OM_stat & *msg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

   if (OM_stat == OM_W_UNKNOWN_MSG) 
   {
     (*count)++;
     OM_stat = OM_S_SUCCESS;
   }
   else
   {
     *count += my_count;
     my_count = 0;
   }
 }  

 wrapup:
  EMWRAPUP(*msg, OM_stat, "In EMScompsurf.GRget_number_components")
  return (OM_stat);
}
end implementation EMScompsurf;
