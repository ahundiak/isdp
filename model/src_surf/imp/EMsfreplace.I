/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMSdpr.h"         /*EMSinlist; EMSoutlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSprop.h"
#include "nddef.h"
#include "ndmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#if DEBUG
#include "stdio.h"
#endif

from EMSassoc import EMastore;
from EMSdpr import EMcorrectOrient, EMoperandChanged,
                   EMsetprops;
from EMSdprparam import EMputGetChangedId;

method EMreplace(IGRlong *EMmsg; GRobjid replacing_id; struct GRmd_env *env; 
                 IGRushort options; GRobjid **display_ids; 
                 IGRint *display_count; GRobjid *active_id)
/*
Description
    This message will replace the target node in the DPR tree with the
    replacing node.  OR will replace this node with the updated version (same
    id) due to an edit operation (see options)
    If not IMMEDIATE_OPER AND if the replacing node is NULL_OBJID the target
    node will be removed.

Return Values
    EMSS_S_Success if all is well.

Notes
    About parameters:
      env - Standard stuff here.

      options:
        EMreplace_DO_DISPLAY - Perform efficient internal display.
        EMreplace_DONT_REDRAW - Don't redraw surfaces.  Instead, return then
                      to the sender.
        EMreplace_DONT_EVAL - Don't evaluate the tree after the replace.  This
                      will leave the replacing node in the tree but
                      unevaluated.
                      Since this option generally will indicate that multiple
                      changes will be occuring to the tree, the replacing id
                      will be stored in the active id via the EMsaveChangedId
                      message.
        EMreplace_IMMEDIATE_OPER - Replace this operation with the updated
                      version due to an edit case.  For this case the
                      replacing_id WILL BE SET TO my_id.  This option
                      essentially unevaluate this operation only rather that
                      the entire limb of the tree. 
      replacing_id - Node to replace me with.  If NULL_OBJID, then this is
                     a node removal operation.

                     NOTE that the replacing_id may also be the same as the 
                     targetid.  This indicates that the node has been modified.

      display_ids - Contains the surfaces erased if options is DO_DISPLAY 
                    AND DONT_REDRAW.  Sender should set pointer to NULL.

      display_count - Number of surfaces in above array.  Sender should set
                      parameter to 0.

      active_id - If no replacing node specified, the active state id after
                  the unevaluation occurs.  This may be the same as before the
                  uneval.                            

    If display_ids is returned, the sender should dealloc the array by
      the om$dealloc macro.

History
    NP  08/24/92 Modified for ANSI compliance. The "GRgraphics.GRchgprops" 
		 method needs the mask as a "IGRshort" unlike the "EMSdpr.
                 EMsetprops" method which expects an "IGRushort". The function
		 "EFisAncestryValid" had not been declared as an "extern". The
		 parameter "EMmsg" had been declared as pointer to "IGRint".
    DLB 02/06/92 Only send EMastore if EMSassoc class AND classids match.
    DLB 02/01/92 Added support for batch_id in EMunevaluate.
    DLB 01/31/92 Removed EMcorrectOrient sends. This logic has always been
                 incorrect.
    DLB 04/14/91 EMputGetChangedId is now at EMSdprparam.
    DLB 01/09/91 Changed GRchgprops to DIchg_member_props for
                 setting and clearing the DI_RIGID_CON bits in
                 the member properties.
    DLB 11/28/90 Removed support for replacing_id == my_id.  Modified to
                 support the new parameter list of EMevaluateOps.
    DLB 11/27/90 Mod EMputGetChangedId send to use channel instead of
                 active_id.  Do this cause the tree will be inactive if in the
                 middle of an update.
    DLB 11/26/90 Use memset to init EMSinlist EMSoutlist.  Also fix problem
                 of owner_id being NULL_OBJID.
    DLB 11/06/90 If IMMEDIATE_OPER don't check for a DPR type owner.  
    SM  07/13/90 Pass the option EMSuneval_IMMEDIATE_OPER to EMunevaluate
                 and ignore UNKNOWN_MSG warning after any send to owner.
    DLB 05/30/90 Added code to handle change in outlist structure to be array
                 of replacing ids.  In this method only one id is ever useds.
    DLB 05/29/90 Added the DONT_EVAL option as indicated above.  Also added the
                 code to handle replacing_id == targetid.
    DLB 11/07/89 Added parameter to EMunevaluate. NOTE that this method DOES
                 NOT currently handle replacing a node this is not part of the
                 dpr tree due to a disjoint case.
    DLB 10/15/89 Modified for recovery if replacing a node.
    DLB 10/08/89 Added EMgetpathlist send and added params to EMevaluateOps.
    DLB 10/02/89 Added EMoperandChanged send.
    DLB 07/20/89 Modified to better handle overlap cases.
    DLB 06/23/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii, comp_type;
  GRobjid           my_owner_id, batch_id;
  IGRushort tmp_options;
  IGRboolean        can_eval=TRUE;
  extern IGRboolean EFisAncestryValid();
  OMuword           dumosnum;
  void              EFreplace_node();
  OM_S_CHANSELECT   to_owners;


  *EMmsg = EMS_S_Success;

  if (replacing_id == my_id) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

  /*Get the owner if one exists*/
  my_owner_id = NULL_OBJID;
  EMmake_chanselect(GRconnector_to_owners, &to_owners);
  OM_stat = om$get_objid_at_index(object = me, 
                                  p_chanselect = &to_owners,
                                  index = 0, 
                                  objidaddr = &my_owner_id, 
                                  osnumaddr = &dumosnum);

  if (!(options & EMreplace_IMMEDIATE_OPER))
  {
    /*If not an immed_op then I must be owned by a DPR*/    

    if (!(1 & OM_stat) || (!EFisAncestryValid(EMmsg, my_owner_id,
                           OM_Gw_current_OS, 
                           OPP_EMSdpr_class_id, FALSE)))
    {
      *EMmsg = EMS_I_InvalidSend;
      goto wrapup;
    }
  }

  OM_stat = OM_S_SUCCESS;

  /*First unevaluate me.*/
  ex$message(msgnumb = EMS_I_UnevalAffecNodes)

  tmp_options = options & EMreplace_DO_DISPLAY ? EMuneval_DO_DISPLAY : NULL;
  tmp_options |= EMuneval_DONT_REDRAW;

  if (replacing_id == NULL_OBJID)
    tmp_options |= (EMuneval_DELETE_SSI | EMuneval_REMOVE_UNEVAL_NODES);

  if (options & EMreplace_IMMEDIATE_OPER) 
    tmp_options |= EMuneval_IMMEDIATE_OPER;
 
  OM_stat = om$send(msg = message EMSsurface.EMunevaluate(EMmsg,
                          tmp_options, env, display_ids, display_count,
                          active_id, NULL_OBJID, &batch_id),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
 
  if (*EMmsg == EMS_I_CantRecompute) 
  {
    can_eval = FALSE;
    goto wrapup;
  }

  if (replacing_id != NULL_OBJID)
  {
#if correctOrient_STUFF_REALLY_WAS_GOOD_AFTER_ALL
    /*First adjust my orientation.*/
    OM_stat = om$send(msg = message EMSdpr.EMcorrectOrient(EMmsg),
                      p_chanselect = &to_owners);
    if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;
    OM_stat = OM_S_SUCCESS;
#endif

    /*Replace me with the replacing_id*/
    EFreplace_node(EMmsg, replacing_id, my_id, OM_Gw_current_OS, &batch_id);
    if (!(1 & *EMmsg)) goto wrapup;

    /*Inform the owner (if one exists) that one of its operands has changed.*/
    
    if (batch_id != NULL_OBJID)
    {
      OM_stat = om$send(msg = message EMSdpr.EMoperandChanged(EMmsg, my_id,
                              replacing_id, NULL),
                        targetid = batch_id);
      if (!(1 & OM_stat & *EMmsg) && (OM_stat!=OM_W_UNKNOWN_MSG)) goto wrapup;
      OM_stat = OM_S_SUCCESS;
    }
  }
  
  if (replacing_id != NULL_OBJID)
  {
    /*If the node being replaced (my_id) is part of the change id list then
     * remove it.
     */
    GRobjid     *tmp_ptr, param_id;
    extern      OMuword OPP_EMSassoc_class_id;
    IGRboolean  EFmatch_classes();


    ii=1;
    tmp_ptr=&my_id;
    OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMputGetChangedId
                                     (EMmsg, &ii, &tmp_ptr,
                                     EMputGetChangedId_DELETE),  
                              replacing_id, OM_Gw_current_OS, &param_id, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    ii=1;
    tmp_ptr=&replacing_id;
    OM_stat = om$send(msg = message EMSdprparam.EMputGetChangedId(EMmsg,
                            &ii, &tmp_ptr,
                            EMputGetChangedId_PUT),  
                      targetid = param_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*Move the parent, dependent (if any), name, notify channels, also match
     * topology and move tags or record mismatch tags.
     */
    if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                          OPP_EMSassoc_class_id, FALSE) &&
        EFmatch_classes(EMmsg, my_id, replacing_id, OM_Gw_current_OS, NULL)) 
    {
      OM_stat = om$send(msg = message EMSassoc.EMastore(EMmsg, NULL, env,
                              replacing_id),
                        targetid = my_id);
    }
    else
    {
      OM_stat = om$send(msg = message EMSsurface.EMmatch_geometry(EMmsg, NULL,
                              env, replacing_id),
                        targetid = my_id);
    }
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  } 

  /*Reevaluate if options IS NOT DONT_EVAL OR
   *              a replace occured OR 
   *              a removal occured and the new active id is a DPR.
   */

  if (!(options & EMreplace_DONT_EVAL) &&
      (replacing_id != NULL_OBJID ||
       EFisAncestryValid(EMmsg, *active_id, OM_Gw_current_OS, 
                         OPP_EMSdpr_class_id, FALSE)))
  {
    struct GRid repl_GRid;


    repl_GRid.objid = (replacing_id == NULL_OBJID) ? batch_id :
                                                     replacing_id;
    repl_GRid.osnum = OM_Gw_current_OS;

    if (repl_GRid.objid != NULL_OBJID)
    {
      ex$message(msgnumb = EMS_I_ReEvalAffecNodes)

      /*Add the changed nodes dependents to the batch*/
   
      /*If removing then make the batch_id get the NDcompute_node,
       * else if replacing, again make the owner get the NDcompute_node.
       */
      comp_type = ND_COMP;

      nd$wait_batch(type = GR_GEOM_POSTED,
                    nb_obj = 1,
                    l_object = &repl_GRid,
                    l_obj_info = (replacing_id == NULL_OBJID) ? &comp_type:
                                                                NULL);
      /*Compute if not deferred.*/
      nd$exec_batch();
    }

    /*--(())-- SEE REMOVED SECTION AT BOTTOM CODE A1*/
    /*How do we check for failure????*/
  }

  /*Do display?*/
  if ((options & EMreplace_DO_DISPLAY) && 
      !(options & EMreplace_DONT_REDRAW))
  {
    /*Redraw the erased surfaces.*/
    /*IMPORTANT NOTE:  
     *  If the unevaluation occurred on a local mod, some surfaces stored in
     *  the display_ids array may no longer exist.  Therefore each id is
     *  checked for validity before sent a display message.  It is felt
     *  that this would be faster and use less code than throwing out the
     *  bad ids at the time that they are deleted.
     */
    enum GRdpmode display_mode=GRbd;  /*DECL*/
    
    for (ii=0; ii<*display_count; ii++)
    {
      if (om$is_objid_valid(objid = (*display_ids)[ii]) == OM_S_SUCCESS)
      {
        OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                                &env->md_env.matrix_type,
                                env->md_env.matrix, &display_mode,
                                &env->md_id),
                          targetid = (*display_ids)[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
  }

  wrapup:
    if ((options & EMreplace_DO_DISPLAY) && 
       !(options & EMreplace_DONT_REDRAW) && 
       *display_ids) 
    {
      om$dealloc(ptr = *display_ids);
      *display_ids = NULL;
      *display_count = 0;
    }

    if (!can_eval && (1 & *EMmsg & OM_stat)) *EMmsg = EMS_I_CantRecompute;
    EMWRAPUP(*EMmsg, OM_stat, "EMSsurface.EMreplace")
    return(OM_stat);
}

void EFreplace_node(EMmsg, replacing_id, node_id, node_os, owner_id)
IGRlong *EMmsg;
GRobjid replacing_id;
GRobjid node_id;
OMuword node_os;
GRobjid *owner_id;
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  OMuword           dumosnum;
  IGRboolean        action;
  IGRushort mask;
  OM_S_CHANSELECT   to_owners;
  extern IGRboolean EFisAncestryValid();


  EMmake_chanselect(GRconnector_to_owners, &to_owners);
  /*Before the move occurs, get my owner id*/
  OM_stat = om$get_objid_at_index(objid = node_id,
                                  osnum = node_os,
                                  p_chanselect = &to_owners,
                                  index = 0,
                                  objidaddr = owner_id,
                                  osnumaddr = &dumosnum);
  if (!(1 & OM_stat)) goto wrapup;

  /*Move the replacing node into my position.*/
  OM_stat = om$send(msg = message Root.move_chan(to_owners,
                          node_id, node_os, to_owners),
                    senderid = node_id,
                    targetid = replacing_id,
                    targetos = node_os);
  if (!(1 & OM_stat)) goto wrapup;

  /*Set the GR_RIGID_REL bit off for the replaced node (node_id).*/
  action = FALSE;
  mask = GR_RIGID_RELATIONSHIP;
  OM_stat = om$send(msg = message GRgraphics.GRchgprops(EMmsg, 
                          &action, (IGRshort *)&mask),
                    senderid = node_id,
                    targetid = node_id,
                    targetos = node_os);                          
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Set the RIGID_REL bit on for the replacing node (replacing_id).*/
  action = TRUE;
  OM_stat = om$send(msg = message GRgraphics.GRchgprops(EMmsg,
                          &action, (IGRshort *)&mask),
                    senderid = node_id,
                    targetid = replacing_id,
                    targetos = node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  /*If node_id is a DPR, make node_id the active state.*/
  if (EFisAncestryValid(EMmsg, node_id, node_os, OPP_EMSdpr_class_id, FALSE))
  {
    action = TRUE;
    mask = EMSIS_ACTIVE_STATE;
    OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, &mask),
                      senderid = node_id,
                      targetid = node_id,
                      targetos = node_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }                              

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFreplace_node")
    return;
}
end implementation EMSsurface;

#if CODE_A1_REMOVED_SINCE_CANT_DETECT_FAILURES_WHEN_COMPUTING_VIA_GRAPH
    if (replacing_id != NULL_OBJID)
    {
      if (*EMmsg == EMS_I_CantRecompute)  
      {
        can_eval = FALSE;

        /*Put me back as the original node.*/
#if correctOrient_STUFF_REALLY_WAS_GOOD_AFTER_ALL
        /*Correct the orientation for the replacing_id*/
        OM_stat = om$send(msg = message EMSdpr.EMcorrectOrient(EMmsg),
                          senderid = replacing_id,
                          p_chanselect = &to_owners);
        if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) 
          goto wrapup;       
        OM_stat = OM_S_SUCCESS;
#endif

        EFreplace_node(EMmsg, my_id, replacing_id, OM_Gw_current_OS,
                       &batch_id); 
        if (!(1 & *EMmsg)) goto wrapup;

#if correctOrient_STUFF_REALLY_WAS_GOOD_AFTER_ALL
        /*Now correct my orientation.*/
        OM_stat = om$send(msg = message EMSdpr.EMcorrectOrient(EMmsg),
                          p_chanselect = &to_owners);
        if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG))
          goto wrapup;
#endif

        OM_stat = OM_S_SUCCESS;
      }
    }
#endif
