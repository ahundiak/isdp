class implementation EMSdpr;

#include "emsdef.h"
#include "EMSerrordef.h"
#include "EMSopt.h"
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSkey.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#if DEBUG
#include "stdio.h"
#endif

from EMSsurface import  EMgetstatedesc;
from EMSxsection import EMdeact_xsection;
from EMSsuppress import EMmove_comps;
from EMSpointerA import EMstore_key_from_id;

method EMdeactivateState(IGRlong           *EMmsg;
                         struct EMSinlist  *inlist;
                         IGRushort flags, options;
                         IGRint            *display_count;
                         GRobjid           **display_ids;
                         struct GRmd_env   *env)
/*
Description
    This message will deactivate those states of a DPR tree needed in
    order to unevaluate a particular node.

Return Values
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added so far.
        flags   - indicates status of this state.  Current values are
                  EMdeact_st_KNOWN_DEPENDENT - this state is a dependent of
                  the node to unevaluate so it must be deactivated.
        options - EMdeact_st_IMMEDIATE_OPER - unevaluation is on an op rather
                    than on an entire limb.
                  EMdeact_st_ADD_MANAGER - add a manager to the state the
                    states being unevaluated.  This should not be specifed
                    when the unevaluated node will be reevaluated without
                    control being returned to the user.
                  EMdeact_st_DELETE_SSI - delete the the SSI info.
                  EMdeact_st_DO_DISPLAY - if internal display is wanted.
        display_count - for use when doing internal display
        display_ids   - dito.

History
    DLB 01/11/93 Fix bug where GetInInfo was being called with is_kdf_on passed
                 after KNOWN_DEP flag had been turned off.  Resulted in
                 param always being set to FALSE.
    DLB 06/10/92 Only issue EMtoggleOrient if have not been undone either via
                 an overlap or due to a EMundo (while in a recompute).  Was
                 issuing a toggleOrient even though I had been undone (but
                 not due to overlap.  TR 92n4980.
    DLB 02/15/92 If issuing EMdeactivate to this node then ALWAYS issue
                 store_key_from_id send (not just if option is DELETE_SSI).
    DLB 11/05/91 Dont reset and set back on ACTIVE_PATH bit around
                 EMsavestatedelete send unless the bit is actually set in the
                 first place.  This can occur quite often and the bug resulted
                 in the ACTIVE_PATH bit set in nodes that were actually
                 inactive.
    DLB 09/03/91 Add EMfixInGeomIds send to handle special case of added
                 surfaces that are removed by the same operation.  The only
                 known case of this is the boolfea class.
    DLB 07/30/91 If making the state NULL, tell any pointers to generate the
                 key before actually doing the NULL op.
    DLB 07/19/91 Supprt suppressed nodes.
    DLB 07/17/91 When making a state NULL also delete the added geometry.
    DLB 06/22/91 Removed ui_echo about skipping the node (not nice if node
                 already uneval'd due to assoc recompute).
    DLB 01/23/91 If IMMEDIATE_OPER known_dependent flags should always be off.
    DLB 11/19/90 Removed code to make this state active for processing.  Can
                 do this since also removing attemptBreakup send.
    BL 06/15/90  Added EMS_UNDO_DONTDELME to deact_options when options is
                 EMdeact_st_DELETE_SSI that prevents the boolean features
                 from deleting themselves.
    DLB 02/04/90 Changed EMtoggleOrient sends to reflect the movement of this
                 msg up to EMSdpr.  Prior to this move, the send by this method
                 to anything other than a boolean class resulted in an unknown
                 msg and the invocation of the GRowner unknown msg handler.
    DLB 12/29/89 Added send to listeners specifically so the xsection will be
                 updated.
    DLB 11/28/89 Added EMgetModRange and EMcheckRngOverlap sends for volume
                 overlap detection.  Currently, this only kicks in for
                 difference operations.
    DLB 11/18/89 No change but edited for ICOM check
    DLB 10/31/89 Added getactiveid send in order to restore the top id to
                 active if an uncomputable node is found above me.
    DLB 10/19/89 If overlap detected undo no matter what. This is necessary in
                 order to get the correct in information.
    DLB xx/xx/89 Many fixes and changes...
    DLB 12/07/88 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            num_chan, ii;
  IGRint            num_added_geom_ids=0;
  GRobjid           *added_geom_ids=NULL;
  struct GRid       active_GRid;
  OM_S_CHANSELECT   to_owners;
  struct EMchanstruct *chan=NULL;
  IGRshort          deact_options;
  IGRboolean        perform_deact=FALSE, turn_off, can_rc, known_dep;
  void              EFcantrc();
# if DEBUG
  IGRchar           my_name[OM_K_MAXCLASS_LEN];
# endif


#if DEBUG
  {
    om$get_classname(object = me,
                     classname = my_name);
  }
# endif


  *EMmsg = EMS_S_Success;

  num_chan = 0;
  active_GRid.objid = NULL_OBJID;

  /*Removed mk_act_st from here*/

  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  known_dep = flags & EMdeact_st_KNOWN_DEPENDENT;

  if (known_dep)
  {
    if (options & EMdeact_st_IMMEDIATE_OPER)
    {
      flags &= ~EMdeact_st_KNOWN_DEPENDENT;
    }
    else
    {
      /*Determine if I can toggle off the KD flag.*/
      OM_stat = om$send(msg = message EMSdpr.EMtoggleKDFlag(EMmsg,
                              &turn_off),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      /*Set the KD flag accordingly.*/
      if (turn_off)
      {
        flags &= ~EMdeact_st_KNOWN_DEPENDENT;
      }
    }

    if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
    {
      /*I am not uneval'd and a known dependent.*/
      perform_deact = TRUE;

#     if DEBUG
      fprintf(stderr,"###deactst - known dependent overlap. %d (%s)\n",
              my_id, my_name);
#     endif

      if (inlist->modlist.mod_id == NULL_OBJID)
      {
        /*Send to possibly get a modified node range.*/
        OM_stat = om$send(msg = message EMSdpr.EMgetModRange(EMmsg, inlist,
                                sender_id, env),
                          targetid = my_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
  }
  else if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
  {
    /*I am not uneval'd and not a KD so see if there is an overlap.*/
    OM_stat = om$send(msg = message EMSdpr.EMcheckOverlap(EMmsg, inlist,
                            &perform_deact, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg))
    {
      perform_deact = TRUE;
#     if DEBUG
      fprintf(stderr,"check overlap failed!\n");
#     endif
    }

#   if DEBUG
    if (perform_deact)
       fprintf(stderr,"###deactst - inlist overlap. %d (%s)\n",
               my_id, my_name);
#   endif

    if (!perform_deact && inlist->modlist.mod_id != NULL_OBJID)
    {
      /*Check for range overlap with mod_id.*/
      OM_stat = om$send(msg = message EMSdpr.EMcheckRngOverlap(EMmsg,
                              inlist->modlist.mod_id,
                              inlist->modlist.range,
                              sender_id,
                              env, &perform_deact, NULL),
                              targetid = my_id);
      if (!(1 & OM_stat & *EMmsg))
      {
        perform_deact = TRUE;
#       if DEBUG
        fprintf(stderr,"check range overlap failed!\n");
#       endif
      }

#     if DEBUG
      if (perform_deact)
        fprintf(stderr,"###deactst - range overlap. %d (%s)\n",
                 my_id, my_name);
#     endif
    }
  }

  if (perform_deact)
  {
    /*First see if node can be recomputed.  If not then simply return will
     * an info message.
     */
    OM_stat = om$send(msg = message EMSdpr.EMcanRecompute(EMmsg, &can_rc),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (!can_rc)
    {
      EFcantrc(EMmsg, my_id, OM_Gw_current_OS);
      *EMmsg = EMS_I_CantRecompute;
      goto wrapup;
    }

    /*Removed mk_act_st and att brk up code from here*/
    OM_stat = om$send(msg = message EMSdpr.EMgetInInfo(EMmsg, inlist,
                            sender_id,
                            known_dep ? TRUE : FALSE, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  /*Continue on up.*/
  OM_stat = om$send(msg = message EMSdpr.EMdeactivateState(EMmsg,
                             inlist, flags, options, display_count,
                             display_ids, env),
                    p_chanselect = &to_owners);
  if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (*EMmsg == EMS_I_CantRecompute)
  {
    /*Removed mk act st from here*/
    goto wrapup;
  }
  else
  {
    /*Notify the listeners...*/
    IGRlong            tmp_msg;
    OM_S_CHANSELECT   notification;
    IGRshort xsect_option;

    xsect_option = EMS_UNDO_DELETE;
    xsect_option |= options & EMdeact_st_DO_DISPLAY ?
                    EMS_DO_DISPLAY | EMS_DONT_REDRAW : NULL;

    EMmake_chanselect(GRnotify_notification, &notification);
    om$send(msg = message EMSxsection.EMdeact_xsection(&tmp_msg,
                  &xsect_option, env, display_ids, display_count),
            p_chanselect = &notification);
  }

  if (perform_deact)
  {
    /*I must deactivate...*/
    ex$message(msgnumb = EMS_I_UnevalAffecNode)
#   if DEBUG
    fprintf(stderr,"Unevaluating node %d (%s)\n", my_id, my_name);
#   endif

    /*Due to random access of tree need to adjust the composite indices stored
     * in this and next states.
     */
    num_chan = 0;
    chan = NULL;
    OM_stat = om$send(msg = message EMSdpr.EMgetCompIndex(EMmsg, &num_chan,
                            &chan, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (num_chan)
    {
      /*Adjust the indices of the next states taking into account this
       * state.
       */
      OM_stat = om$send(msg = message EMSdpr.EMputCompIndex(EMmsg, num_chan,
                              chan, NULL),
                        p_chanselect = &to_owners);
      if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      /*Now adjust indices of this state taking into account the next
       * states.
       */
      OM_stat = om$send(msg = message EMSdpr.EMputCompIndex(EMmsg, num_chan,
                              chan, EMput_comp_inx_DONT_SEND_UP),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    if (options & EMdeact_st_DELETE_SSI)
    {
      /*Get added geom (if any, localmods), record ids & indices to me,
       * then remove'em.
       */
      OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg,
                              NULL_OBJID, FALSE,
                              &num_added_geom_ids,
                              &added_geom_ids, NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
    {
      OMuint  children_count;
      IGRlong loc_msg,status,ii;
      OM_S_CHANSELECT to_children;

      /*DLB 2/15/92-Moved store_key to here from DELETE_SSI place above*/
      EMmake_chanselect(NDchildren_children, &to_children);

      status = om$get_channel_count(p_chanselect = &to_children,
                                objid = my_id,
                                count = &children_count);
      if (!(1&status)) goto wrapup;

      for (ii=0;ii<children_count;ii++)
      {
        om$send (msg = message EMSpointerA.EMstore_key_from_id(&loc_msg,
                    EMS_OPT_STORE_ID, NULL),
                    p_chanselect = &to_children,
                    from = ii,
                    to = ii);
      }

      if (ME.EMSdpr->dpr_props & EMS_ORIENT_FLIPPED)
      {
        /*Need to flip back my orientation since the deact will also flip it.
         * Note- The most efficient way of doing this is for the deact code
         *       to recognize the bit and not flip.  However, due to the
         *       uncertainty of such a change, and little time to make it, I
         *       will just be a little less efficient. DLB 1/31/92
         */
        OM_stat = om$send(msg = message EMSdpr.EMtoggleOrient(EMmsg, NULL),
                          targetid = my_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }

      /*Added if since evalops could cause this node to be inactive
       * BL  06/15/90  Added EMS_UNDO_DONTDELME to deact_options
       * DLB 07/22/91  Always do undo save in order to keep any added
       *               surfaces (necessary for node suppression interface.
       */
      deact_options = EMS_UNDO_SAVE;
      deact_options |= (options & EMdeact_st_DO_DISPLAY ? EMS_DO_DISPLAY :
                                                          NULL);
      OM_stat = om$send(msg = message EMSdpr.EMdeactivate(EMmsg,
                              &deact_options, env, display_ids,
                              display_count),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      OM_stat = om$send(msg = message EMSdpr.EMfixInGeomIds(EMmsg, env,
                              NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg) && OM_stat != OM_W_REJECTED_METHOD)
        goto wrapup;
      else OM_stat = OM_S_SUCCESS;
    }

    /*This state is now uneval'd.*/
    ME.EMSdpr->dpr_props |= EMS_UNEVAL_STATE;

    if (options & EMdeact_st_DELETE_SSI)
    {
      GRobjid suppress_id;
      IGRboolean turn_act_path_back_on=FALSE;

      OM_stat = EFcreate_suppress_id(EMmsg, my_id, OM_Gw_current_OS,
                                     &suppress_id, NULL);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      OM_stat = om$send(msg = message EMSsuppress.EMmove_comps(EMmsg,
                              my_id, TRUE,
                              num_added_geom_ids, added_geom_ids, NULL),
                        targetid = suppress_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
      {
        ME.EMSdpr->dpr_props &= ~EMSIS_ACTIVE_PATH;
        turn_act_path_back_on = TRUE;
      }
      OM_stat = om$send(msg = message EMSdpr.EMsavestatedelete(EMmsg, env,
                              NULL),
                        targetid = my_id);
      if (turn_act_path_back_on) ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_PATH;
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      OM_stat = om$send(msg = message EMSdpr.EMresetSSI(EMmsg),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto  wrapup;

      /*This state is now NULL.*/
      ME.EMSdpr->dpr_props |= EMS_NULL_STATE;
    }

    if ( !known_dep && (options & EMdeact_st_ADD_MANAGER) )
    {
      /*Add a shell manager to the unevaluated guy.*/
      OM_stat = om$send(msg = message EMSdpr.EMaddManager(EMmsg, sender_id,
                              FALSE, NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }
  else
  {
    /***ui_status("Skipping unaffected node"); DLB 6/22/91***/
#   if DEBUG
    if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
     fprintf(stderr,"deactst - skipping unaffected %d (%s)\n", my_id, my_name);
#   endif

    if (!(ME.EMSdpr->dpr_props & EMS_ORIENT_FLIPPED) &&
        ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH) /*Dont if undone DLB6/10/92*/
    {
      /*No deactivate (due to overlap) had occured and my orientation has not
       * been flipped.
       * Now handle the orientation change for difference booleans.
       */
      OM_stat = om$send(msg = message EMSdpr.EMtoggleOrient(EMmsg,
                              EMtoggle_orient_FLIP_AS_IF_INACTIVE),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  wrapup:
    for(ii=0; ii<num_chan; ii++)
    {
      if (chan[ii].chan) om$dealloc(ptr = chan[ii].chan);
    }
    if (chan) om$dealloc(ptr = chan);
    if (added_geom_ids) om$dealloc(ptr = added_geom_ids);

    EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMdeactivateState")
    return(OM_stat);
}

void EFcantrc(EMmsg, node_id, node_os)
IGRlong *EMmsg;
GRobjid node_id;
OMuword node_os;
{
  IGRlong OM_stat=OM_S_SUCCESS;
  IGRchar desc_str[54], print_str[128];

# if DEBUG
   fprintf(stderr, "Node %d can not recompute.\n", node_id);
# endif

  *EMmsg = EMS_S_Success;
  OM_stat = om$send(msg = message EMSsurface.EMgetstatedesc(EMmsg, desc_str),
                    senderid = NULL_OBJID,
                    targetid = node_id,
                    targetos = node_os);
  if (1 & OM_stat & *EMmsg)
  {
    ex$message(msgnumb = EMS_I_NodeIdAffectsNodeCantRecomp, buff = print_str)
    strcat(print_str, " ( ");
    strcat(print_str, desc_str);
    strcat(print_str, " )");
    UI_status(print_str);
  }
  return;
}
end implementation EMSdpr;


#if NEED_MAKE_ACT_ST0
  DLB 11/18/90
  if (!(EMSdpr->dpr_props & EMSIS_ACTIVE_PATH))
  {
    /*A last state has undone me so make me active again.*/
#   if DEBUG
    fprintf(stderr,"Redoing node %d\n", my_id);
#   endif

    temp_opt = NULL;
    OM_stat = om$send(msg =  EMSsurface$EMmake_active_state(EMmsg,
                            &temp_opt, env, NULL, NULL, NULL, NULL, NULL,
                            NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }
#endif


#if NEED_MAKE_ACT_ST1
    DLB 11/18/90
    /*Moved EMmake_active_state code from EMattemptBreakup to here.10/19/89*/
    /*Since the following 2 messages rely on this state to be the active state
     * I must make me active.  This is a somewhat painful step but if it saves
     * a recompute then it is worthwhile.
     */
    if (!(EMSdpr->dpr_props & EMSIS_ACTIVE_STATE))
    {
#     if DEBUG
        fprintf(stderr,"Undoing node %d\n", my_id);
#     endif

      /*Before undoing get the active state.  If an above node can't recompute
       * then need to again make the to node active.
       */
      OM_stat = om$send(msg =  EMSsurface$EMgetactiveid(EMmsg,
                              &active_GRid, NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      temp_opt=EMS_TEMP_UNDO;
      OM_stat = om$send(msg =  EMSsurface$EMmake_active_state(EMmsg,
                              &temp_opt, env, NULL, NULL, NULL, NULL, NULL,
                              NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    /*I now will see if this node can be broken up into multiple nodes.
     * I attempt this because this state may have actually had multiple
     * (possibly independent) operations performed during creation.
     * This send will break up the operation if possible into seperate
     * DPR's.  An obvious example of such a situation is multiple booleans.
     * If a break up does occur, the state to deactivate  will still be me
     * and the next state will the unaffected portions of me.
     * The EMattemptBreakup message will take care of moving the
     * SSI info into the new state.
     */

    OM_stat = om$send(msg =  EMSdpr$EMattemptBreakup(EMmsg,
                            sender_id,
                            &did_breakup,
                            &new_state_id,
                            env,
                            NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
#endif

#if NEED_MAKE_ACT_ST2
    if (active_GRid.objid != NULL_OBJID && active_GRid.objid != my_id)
    {
      /*First restore the top guy to active.*/
      temp_opt=NULL;
      OM_stat = om$send(msg =  EMSsurface$EMmake_active_state(EMmsg,
                              &temp_opt, env, NULL, NULL, NULL, NULL, NULL,
                              NULL),
                        targetid = active_GRid.objid);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      *EMmsg = EMSI_I_CantRecompute;
    }
#endif
