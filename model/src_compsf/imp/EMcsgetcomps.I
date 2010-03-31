/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "msdef.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsubbs_class_id;

method GRget_components(IGRlong *msg; struct GRmd_env *env;
                        struct GRid objects[]; IGRint number_objects;
                        IGRint *count; IGRint from_obj; IGRint to_obj)
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
 IGRint          my_count,  i;
 struct GRid     my_obj, *id_list;
 OM_S_CHANSELECT to_comps;
 void            EFgetobjids();


 OM_stat = OM_S_SUCCESS;
 *msg = MSSUCC;

 *count = 0;
 my_count = 0;
 id_list = NULL;

 to_comps.type = OM_e_addr;
 to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

 OM_stat = om$get_channel_count(object = me, 
                                p_chanselect = &to_comps,
                                count = &comp_count);
 if (!(1 & OM_stat)) goto wrapup;

 for (i = 0; i < comp_count; i ++)
 {
   /*Get leaf components of my components that are also composites*/
   OM_stat = om$send(msg = message GRowner.GRget_components(msg, env,
                           &objects[*count], number_objects - *count,
                           &my_count, from_obj, to_obj), 
                     p_chanselect = &to_comps,
                     from = i, to = i);
   if (!(1 & OM_stat & *msg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

   if (OM_stat != OM_W_UNKNOWN_MSG)
   {
     *count += my_count;
     my_count = 0;
   }
   else 
     OM_stat = OM_S_SUCCESS;
 }  

 /*Get my components that are leaf components*/
 my_obj.objid = my_id;
 my_obj.osnum = OM_Gw_current_OS;

 EFgetobjids(msg, &my_obj, &to_comps, &id_list, &my_count,
             OPP_EMSsubbs_class_id, NULL, NULL);
 if (!(1 & *msg)) goto wrapup;
 
 if (my_count + *count > number_objects) {*msg = MSFAIL; goto wrapup;}

 if (my_count)
   OM_BLOCK_MOVE(id_list, &objects[*count], my_count * sizeof(struct GRid));

 *count += my_count;

 wrapup:
  if (id_list) om$dealloc(ptr = id_list);
  EMWRAPUP(*msg, OM_stat, "In EMScompsurf.GRget_number_components")
  return (OM_stat);
}
end implementation EMScompsurf;
