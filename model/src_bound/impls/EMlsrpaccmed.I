/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
method EMmk_act_cm_eds_connectable (
 IGRlong           *EMmsg;
 IGRint            tree_depth;
 struct  GRmd_env  *md_env;
 IGRint            *num_act_cm_eds;
 IGRint            *act_cm_eds_buf_size;
 GRobjid           **act_cm_eds;
 IGRint            *num_new_cm_eds;
 IGRint            *new_cm_eds_buf_size;
 GRobjid           **new_cm_eds)

/*
 Description

   This method checks if the common edge (if any) of the edge is
   a part of an active loop or not. If so, it replaces the common
   edge by its compressed copy and returns this information
   if the user requests so.

   It is assumed that the edge is currenntly inactive. 

   If the user does not want act_cm_eds or new_cm_eds, they can
   be passed in as NULL.

Arguments

 EMmsg               -  Return code.
 tree_depth          -  Variable stating how many loop depths from the
                        loopset or from a given loop does this message
                        need to be processed.
 md_env              -  Module Environment information. 
 num_act_cm_eds      -  Num of active common edges.
 act_cm_eds_buf_size -  Buf size of active common edges array. If none
                        *act_cm_eds_buf_size should be set to NULL.
 act_cm_eds          -  Active common edges array. Iif caller does not 
                        wants it, act_cm_eds should be set to NULL.
 num_new_cm_eds      -  Number of new common edges
 new_cm_eds_buf_size -  Buf size of new common edges array. If none, 
                        *new_cm_eds_buf_size should be set to NULL.
 new_cm_eds          -  New common edges array. If the caller does not
                        want it, new_cm_eds should be set to NULL.

History

   RC     05/12/88        Creation Date

*/

{
  OM_S_CHANSELECT        to_loops;
  IGRlong                OM_stat;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  EMerr_hndlr (tree_depth < 1, *EMmsg, EMS_E_InvalidArg, wrapup);

  to_loops.type = OM_e_addr;
  to_loops.u_sel.addr = &ME.EMSloopset->to_loops;

  OM_stat = om$send (msg = OPPmargs,
                     p_chanselect = &to_loops);
  EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_LoopError,wrapup);

wrapup:
    EMWRAPUP (*EMmsg,OM_stat,"In EMSloopset.EMmk_act_cm_eds_connectable");

 return(OM_stat);

} 

end implementation EMSloopset;
