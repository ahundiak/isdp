/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSmsgdef.h"
#include "EMSdpr.h"
#include "emsdef.h"
#include "EMSopt.h"
#if DEBUG
#include "stdio.h"
#endif

method EMrecover(IGRlong *EMmsg; 
                 IGRint num_compute_info; 
                 struct EMScompute_info *compute_info; 
                 struct GRmd_env *env; 
                 IGRushort options)
/*
Description
    This method will traverse down the dpr tree returning nodes to their
    original states before they were recomputed.

Return Values
    EMS_S_Success if all is well

Notes
    About parameters:
        options - None so far.

History
    DLB 06/27/91    Do not restore computed nodes; just suppress them.
    DLB 11/04/90    Now supporting for added surfaces produced by local mods.
    DLB 11/11/89    Added code if props & CONVERTED_TO_CS.
    DLB 10/14/89    Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii;
  OM_S_CHANSELECT   to_comps;
  IGRshort          tmp_options;
  IGRboolean        did_recompute = FALSE;


  *EMmsg = EMS_S_Success;

  /*Am I a recomputed node?*/
  for(ii=0; ii<num_compute_info; ii++)
  {
    if (compute_info[ii].computed_id == my_id)
    {
      did_recompute = TRUE;
      break;
    }
  }

  if (did_recompute)
  {
    tmp_options = EMS_UNDO_DELETE | EMS_UNDO_DONTDELME;
    OM_stat = om$send(msg = message EMSdpr.EMdeactivate(EMmsg, &tmp_options, 
                            env, NULL, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    ME.EMSdpr->dpr_props &= ~EMSIS_ACTIVE_PATH;
  
    OM_stat = om$send(msg = message EMSdpr.EMresetSSI(EMmsg),
                      targetid = my_id);
    if (! (1 & OM_stat & *EMmsg)) goto wrapup;                     

    ME.EMSdpr->dpr_props |= (EMS_UNEVAL_STATE | EMS_NULL_STATE);
  }
  
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$send(msg = message EMSdpr.EMrecover(EMmsg, 
                          num_compute_info, compute_info, env, options),
                    p_chanselect = &to_comps);
  if (! (1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
  else OM_stat = OM_S_SUCCESS;
  
#if EVER_WISH_TO_ATTEMPT_TO_RESTORE_THE_ORIGINAL_DURING_AN_UPDATE_SITUTATION
  if (did_recompute)
  {
    /*Now restore this node to is original state.*/
    IGRint jj;
    struct GRid my_GRid;

    /*Reconnect added surfaces. DLB 11/04/90*/
    my_GRid.objid = my_id,
    my_GRid.osnum = OM_Gw_current_OS;   
    for(jj=0; jj<compute_info[ii].added_geom.num_added; jj++)
    {
      OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                              &my_GRid, 
                              compute_info[ii].added_geom.added_inx[jj]),
                        targetid = compute_info[ii].added_geom.added_ids[jj]);
    }

    OM_stat = om$send(msg = message EMSdpr.EMconnectTopology(EMmsg,
                            &compute_info[ii].con_top, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    OM_stat = om$send(msg = message EMSdpr.EMputSSI(EMmsg, 
                            compute_info[ii].ssi),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (compute_info[ii].ri)
    {
      OM_stat = om$send(msg = message EMSdpr.EMputRI(EMmsg, 
                              compute_info[ii].ri),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    tmp_options = NULL;
    OM_stat = om$send(msg = message EMSdpr.EMactivate(EMmsg,
                            &tmp_options, env, NULL, NULL), 
                      targetid = my_id);
    ME.EMSdpr->dpr_props &= ~EMS_UNEVAL_STATE;
    ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_PATH;

    tmp_options = EMcleanup_compute_info_FREE_ONLY |
                  EMcleanup_compute_info_DONT_SEND_DOWN;
    OM_stat = om$send(msg = message EMSdpr.EMcleanupComputeInfo(EMmsg, 
                            tmp_options, env, 1, &compute_info[ii]),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if (ME.EMSdpr->dpr_props & EMS_CONVERTED_TO_CS)
  {
    void EFconvert_to_sl();

    EFconvert_to_sl(EMmsg, my_id, OM_Gw_current_OS, NULL);
    if (!(1 & *EMmsg)) goto wrapup;
      
    if (*EMmsg == EMS_I_ChangeClass)
    {
      /*Conversion occured so reset the bit.*/
      /*IMPORTANT - I have just changed class so DO NOT access instance data
       *            directly.
       */
      IGRboolean action=FALSE;
      IGRushort mask=EMS_CONVERTED_TO_CS;

      OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action,
                              &mask),  
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

#     if DEBUG
      fprintf(stderr,"Node %d converted to sl\n", my_id);    
#     endif    
    }
  }
#endif

  wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMrecover")
   return(OM_stat);
}
end implementation EMSdpr;
