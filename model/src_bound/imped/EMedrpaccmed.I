/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

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

   This method checks if it is not active and the common edge (if any) 
   of the edge is
   a part of an active loop or not. If so, it replaces the common
   edge by its compressed copy and returns this information
   if the user requests so.

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
  OM_S_CHANSELECT        cm_ed_chan, ed_lp_chan, lp_ed_chan;
  struct EMSpartolbasis  partolbasis;
  IGRlong                OM_stat;
IGRlong   mthd_stat;
IGRlong   rc;
  IGRint                 stat;
IGRint   INITIAL_SIZE, BUF_INC, EMsend_loops();
  int                    cm_ed_inx;
  GRobjid                cm_ed_id, cm_ed_cp_id, cm_ed_lp_id, my_lp_id;
  void                   EFmemory_allocation();
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  cm_ed_chan.type = OM_e_addr;
  cm_ed_chan.u_sel.addr = &ME.EMSedge->to_common_edge;

  cm_ed_id = NULL_OBJID;
  OM_stat = om$send (msg = message EMSboundary.EMget_objid (EMmsg,
                      &cm_ed_id),
                     p_chanselect = &cm_ed_chan);
  EMerr_hndlr (!(1 & OM_stat & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (cm_ed_id != NULL_OBJID)
  {
    my_lp_id = NULL_OBJID;
    stat = EMsend_loops (&mthd_stat, 
                         message EMSboundary.EMget_objid (&mthd_stat,
                          &my_lp_id),
                         my_id, NULL, OM_K_MAXINT, EMLP_ACTIVE, NULL,
                         NULL);
    EMerr_hndlr (!(1&stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    if (my_lp_id == NULL_OBJID)
    {
      cm_ed_lp_id = NULL_OBJID;
      stat = EMsend_loops (&mthd_stat, 
                           message EMSboundary.EMget_objid (&mthd_stat,
                           &cm_ed_lp_id),
                           cm_ed_id, NULL, OM_K_MAXINT, EMLP_ACTIVE, NULL,
                           NULL);
      EMerr_hndlr (!(1&stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

      if (cm_ed_lp_id != NULL_OBJID)
      {
        OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        OM_stat = om$send (msg = message EMSboundary.EMtpcopy (&mthd_stat,
                            md_env, OM_Gw_current_OS, 
                            OM_Gw_current_OS, NULL, &cm_ed_cp_id),
                           targetid = cm_ed_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        OM_stat = om$get_index (objid_c = cm_ed_lp_id,
                                p_chanselect = &lp_ed_chan,
                        objid = cm_ed_id, indexaddr = (OMuint *)&cm_ed_inx);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        OM_stat = om$send (msg = message Root.connect (ed_lp_chan,
                            cm_ed_inx, cm_ed_lp_id, OM_Gw_current_OS, 
                            lp_ed_chan, NULL),
                           targetid = cm_ed_cp_id);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        partolbasis.is_valid = FALSE;
        partolbasis.mattyp = &md_env->md_env.matrix_type;
        partolbasis.mat = md_env->md_env.matrix;

        OM_stat = om$send (msg = message EMSboundary.EMcompress_top (
                            &mthd_stat, &partolbasis, &cm_ed_cp_id),
                           targetid = cm_ed_cp_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

        OM_stat = om$send (msg = message Root.disconnect (lp_ed_chan,
                            cm_ed_id, OM_Gw_current_OS, ed_lp_chan),
                           targetid = cm_ed_lp_id);
        EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror,wrapup);

        INITIAL_SIZE = BUF_INC = 4;

        if (act_cm_eds)
        {
          EFmemory_allocation (&rc, (IGRchar **) act_cm_eds,
                               (*num_act_cm_eds + 1), act_cm_eds_buf_size,
                              sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

          (*act_cm_eds)[(*num_act_cm_eds)++] = cm_ed_id;

        } /* if (act_cm_eds) */
    
        if (new_cm_eds)
        {
          EFmemory_allocation (&rc, (IGRchar **) new_cm_eds,
                              (*num_new_cm_eds + 1), new_cm_eds_buf_size,
                              sizeof(GRobjid), INITIAL_SIZE, BUF_INC);
          EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

          (*new_cm_eds)[(*num_new_cm_eds)++] = cm_ed_cp_id;

        } /* if (new_cm_eds) */
    
      } /* if (cm_ed_lp_id != NULL_OBJID) */

    } /* if (my_lp_id == NULL_OBJID) */

  } /* if (cm_ed_id != NULL_OBJID) */

wrapup:
    EMWRAPUP (*EMmsg,OM_stat,"In EMSedge.EMmk_act_cm_eds_connectable");

 return(OM_stat);

} 

end implementation EMSedge;
