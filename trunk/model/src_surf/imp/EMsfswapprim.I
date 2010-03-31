class implementation EMSsurface;

#include "EMSopt.h"
#include "EMSdpr.h"
#include "nddef.h"
#include "ndmacros.h"

from EMSdprparam import EMget_display_ids, EMput_display_ids,
                        EMputGetChangedId; 
from EMSsfboolean import EMget_put_cht;

method EMswapPrimitive(IGRlong *EMmsg; struct GRmd_env *my_env;
                       GRobjid swap_id; IGRushort options)
/*
Description
    This message should be sent to a primitive to be replaced with new_id.

Return Values
    EMS_S_Success       - all is well.
    EMS_E_Fail          - if a failure occurred.

Notes
    About options parameter:
    
      EMS_DO_DISPLAY - if set this message will handle the erasing and
                       drawing of the solid. 
      EMS_DONT_REEX  - if set dont recompute the tree.
           
    The following assumptions are made regarding this message:

    1) This message is defined for use by Salvagnini Transferica ONLY. 

    2) This message is only valid for boolean trees.  However, no validity
       check is made.

    3) This message should be sent to a valid primitive (i.e. NOT to a
       surface of a solid).  No validity check is made for this either.
       
History
    DLB 11/18/88 Creation.
    NP  09/24/92 Modified for ANSI compliance. Changed "my_owner_to_comp_index"
                 and "swap_owner_to_comp_index" to "IGuint" as needed by 
                 om$get_index and typecast it as "IGRlong" for the 
                 "GRconnector.GRrigidconn" method.
    DLB 10/26/92 Use uneval/eval technology.
    WBC 12/17/93 The display_ids need to be posted to the EMSdprparam object
                 in case they have changed.
*/
{
  IGRdouble         my_owner_cht, swap_owner_cht;
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRuint           swap_owner_to_comp_index, my_owner_to_comp_index;
  IGRint            display_count=0;
  GRobjid           *display_ids=NULL, param_id=NULL_OBJID, 
                    my_batch_id, swap_batch_id, tmp_active_id;
  struct GRid       my_owner_GRid, swap_owner_GRid;
  OM_S_CHANSELECT   to_owners, to_comps;
  IGRushort         tmp_options;
  IGRboolean        update_display_ids = FALSE;

  *EMmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners);
  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
                               
  /*Get my owners id.*/
  OM_stat = om$get_objid_at_index(object = me,
                                  p_chanselect = &to_owners,
                                  index = 0,
                                  objidaddr = &my_owner_GRid.objid,
                                  osnumaddr = &my_owner_GRid.osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Get my owner to_comp channel index to me because I must connect the
   * swap_id to his same index.
   */
  OM_stat = om$get_index(objid_c = my_owner_GRid.objid,
                         p_chanselect = &to_comps,
                         objid = my_id,
                         indexaddr = &my_owner_to_comp_index);
  if (!(1 & OM_stat)) goto wrapup;                         

  /*Get the swap_id's owner id.*/
  OM_stat = om$get_objid_at_index(objid = swap_id,
                                  p_chanselect = &to_owners,
                                  index = 0,
                                  objidaddr = &swap_owner_GRid.objid,
                                  osnumaddr = &swap_owner_GRid.osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Get the swap_ids owner to_comp channel index to it because I must
   * connect me to his same index.
   */
  OM_stat = om$get_index(objid_c = swap_owner_GRid.objid,
                         p_chanselect = &to_comps,
                         objid = swap_id,
                         indexaddr = &swap_owner_to_comp_index);
  if (!(1 & OM_stat)) goto wrapup;                         

  OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(
                                   EMmsg, &display_count, &display_ids, NULL),
                            my_id, OM_Gw_current_OS, &param_id, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                         

  update_display_ids = TRUE;

  /*Unevaluate me.*/
  tmp_options = EMuneval_DELETE_SSI;
  tmp_options |= (options & EMS_DO_DISPLAY) ? 
                 (EMuneval_DO_DISPLAY | EMuneval_DONT_REDRAW) : NULL;

  OM_stat = om$send(msg = message EMSsurface.EMunevaluate(EMmsg,
                          tmp_options, my_env, &display_ids, &display_count,
                          &tmp_active_id, NULL_OBJID, &my_batch_id),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  /*Unevaluate the swap id.*/
  OM_stat = om$send(msg = message EMSsurface.EMunevaluate(EMmsg,
                          tmp_options, my_env, &display_ids, &display_count,
                          &tmp_active_id, NULL_OBJID, &swap_batch_id),
                    targetid = my_id);

  /*Disconnect me.*/
  OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                          &my_owner_GRid),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
  /*Disconnect the swap id.*/
  OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                          &swap_owner_GRid),
                    targetid = swap_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Replace me with the swap_id.*/
  OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                          &my_owner_GRid, 
                          (IGRlong *) &my_owner_to_comp_index),
                    targetid = swap_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Replace swap_id with me.*/
  OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                          &swap_owner_GRid,
                          (IGRlong *) &swap_owner_to_comp_index),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Get my owners cht (this must be swapped as well).*/
  OM_stat = om$send(msg = message EMSsfboolean.EMget_put_cht(EMmsg, FALSE,
                          &my_owner_cht),
                    targetid = my_owner_GRid.objid);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Get the swap owners cht.*/
  OM_stat = om$send(msg = message EMSsfboolean.EMget_put_cht(EMmsg, FALSE,
                          &swap_owner_cht),
                    targetid = swap_owner_GRid.objid);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Put my owners cht in swap owner.*/
  OM_stat = om$send(msg = message EMSsfboolean.EMget_put_cht(EMmsg, TRUE,
                          &my_owner_cht),
                    targetid = swap_owner_GRid.objid);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Put swap owners cht in my owner.*/
  OM_stat = om$send(msg = message EMSsfboolean.EMget_put_cht(EMmsg, TRUE,
                          &swap_owner_cht),
                    targetid = my_owner_GRid.objid);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Prepare to update.*/  
  { /*Record me and swap id in change id list*/
    IGRint  ii=1;
    GRobjid *tmp_ptr;

    tmp_ptr=&my_id;
    OM_stat = om$send(msg = message EMSdprparam.EMputGetChangedId(EMmsg,
                            &ii, &tmp_ptr,
                            EMputGetChangedId_PUT),  
                      targetid = param_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    tmp_ptr=&swap_id;
    OM_stat = om$send(msg = message EMSdprparam.EMputGetChangedId(EMmsg,
                            &ii, &tmp_ptr,
                            EMputGetChangedId_PUT),  
                      targetid = param_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  { /*Throw my boolean and swap id boolean on batch.*/
    struct GRid repl_GRid;

    repl_GRid.objid = my_id;
    repl_GRid.osnum = OM_Gw_current_OS;
    nd$wait_batch(type = GR_GEOM_POSTED,
                  nb_obj = 1,
                  l_object = &repl_GRid,
                  l_obj_info = NULL);

    repl_GRid.objid = swap_id;
    nd$wait_batch(type = GR_GEOM_POSTED,
                  nb_obj = 1,
                  l_object = &repl_GRid,
                  l_obj_info = NULL);
  }
  
  if (!(options & EMS_DONT_REEX))
  {
    nd$exec_batch();
  }

wrapup:

  if (update_display_ids)
  {
    OM_stat= om$send(msg = message EMSdprparam.EMput_display_ids(
                                   EMmsg, display_count, display_ids, NULL),
                     targetid = param_id);
  }

  EMWRAPUP(*EMmsg, OM_stat, "sf.EMswapPrim")
  return(OM_stat);
}
end implementation EMSsurface;
