/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"

method EMisClassInTree(IGRlong *EMmsg;  OMuword *classid; 
                       IGRushort num_classid; IGRboolean *flag;
                       IGRboolean search_up)
/*
Description
   Flag is true if the input classes are equal to or are SUBCLASSES of the
   class in the tree.

   If search_up is TRUE then traversal will be up the tree.
   A downward search for this class is invalid and is ignored.

History
   DLB    03/21/88   Creation.
   NP     08/26/92   Modified for ANSI compliance.
*/

{
 IGRlong  OM_stat;
 IGRushort   i; /* has to be same type as "num_classid" in the for loop, for ANSI. */
 OMuword  my_classid;


 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 OM_stat = om$get_classid(object = me,
                          p_classid = &my_classid);
 if (!(1 & OM_stat)) goto wrapup;

 *flag = FALSE; 

 for (i = 0; i < num_classid; i ++)
 {
   OM_stat = om$is_ancestry_valid(superclassid = classid[i],
                                  subclassid = my_classid);
   if (!(1 & OM_stat)) goto wrapup;

   if (OM_stat == OM_S_SUCCESS || my_classid == classid[i]) 
   {
     *flag = TRUE;
     OM_stat = OM_I_STOP_SENDING;
     goto wrapup;
   }
 }

 if (search_up)
 {
   OM_S_CHANSELECT to_owners;    /*DECL*/

   to_owners.type = OM_e_addr;
   to_owners.u_sel.addr = &ME.GRconnector->to_owners;

   OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_owners,
                     from = 0, to = 0);
   if (!(1&OM_stat&*EMmsg) && (OM_stat!=OM_W_UNKNOWN_MSG)) goto wrapup;
 }
 
 OM_stat = OM_S_SUCCESS;  /*Set return code so WRAPUP doesn't complain*/

 wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMisClassInTree")
   return(OM_stat);
}
end implementation EMSsubbs;
