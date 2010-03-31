class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSprop.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMminimum.h"
#include "memory.h"
#include "gocmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "nddef.h"
#include "EMSssprops.h"

#if DEBUG
#include "stdio.h"
#endif

from EMSsubbs    import EMpassloop, EMset_props, EMput_range_in_rtree;
from EMSboundary import EMget_edges;
from EMSsfdpr    import EMgetsolidclass;
from EMSdprparam import EMget_display_ids, EMget_compute_info,
                        EMput_display_ids, EMdisplay, EMdelete,
                        EMputGetChangedId, EMsetStatus, EMgetStatus;
from EMSsuppress import EMget_suppress_id, EMmove_comps, EMget_suppressed_geom;
from EMSpointerA import EMstore_id_from_key;
from NDnode      import NDmove_to_root;

extern OMuword OPP_EMSsolid_class_id;
extern IGRboolean WANT_POST220_BEHAVIOR;

method EMevaluateOps(IGRlong           *EMmsg; 
                     IGRushort options; 
                     struct GRmd_env   *env;
                     IGRint            parent_count;
                     struct GRid       *parent_list;
                     IGRuint   type;
                     IGRchar           *recomp_info)
/*
Description
    This message will evaluate operation nodes in the DPR tree. 

Return Values
    EMSS_S_Success if all is well.

Notes
    About parameters:
      options:
        EMeval_op_DONT_CHECK_DEPENDENTS - Do not proceed up the tree checking
          for dependents.  This option should only be used when the sender is
          ABSOLUTELY sure that ALL dependents of this node will recompute
          due to already being unevaluated.  The initial reason for adding
          this option is for removing nodes from the tree.
        EMeval_op_DO_DISPLAY - perform efficient internal display.

        The following options are added for associativity to work.

        EMeval_op_NO_REMOVE_FROM_RT - do not remove the old guy from the
                                      rtree.
        EMeval_op_NO_ADD_TO_RT      - do not add the new guy from the rtree.

      env - current environment.

    WARNING: The support for display ids has shifted from parameters of this
    message to a 'parameter' object connected to the top of the DPR tree.  The
    get and put messages for this object simply pass the pointers to the arrays
    that are stored in the EMSdprparam object.  This causes a behaviour similar
    to the abstract buffer for geometry.  That is, if, for example, the
    EMget_display_ids is used and new ids are added then a EMput_display_ids
    MUST be done before any other function call or message send that might
    also add display ids.  If not done the each will overwrite the others
    items in the array.    

History
   WBC  12/17/93 Update the display_ids in the EMSdprparam object at the end
                 of the method if necessary.  Currently, if an error is
                 returned by certain method/function calls, the display_ids
                 may not be posted.
   Jack 06/02/93 Added dealloc for "outlist.lplist.loop_ids" to fix Purify 
                 memory leak.  Did same thing for "outlist.sflist.surf_ids",
                 "outlist.edlist.edge_ids" and "outlist.sfmodlist.surf_ids."
    DLB 02/16/93 Patch boolfea bug where activate doesn't redraw all surfs.
                  TR 119301118
    DLB 01/08/93 Remember setting of MACRO_STATE bit during recompute.
    DLB 12/10/92 Even if no overlap found then go on and check for converted to
                 cs and change back if possible.
    DLB 11/20/92 Check for EMS_DELETE property.  If set do everything but
                 perform the EMreex send.  Then mimick a failure.
    DLB 03/13/92 Call EFcomp_stitchable to determine conversion between sf/sl
                 this function will do stitchable - non-degenerate edge check.
    DLB 02/25/92 If ACTIVE_PATH dont issue EMundo is I can't recompute(!can_rc)
    DLB 02/25/92 If converting to surface and a EMSslboolfea class then
                 convert to EMSsfboolean.
    DLB 02/13/92 Added EMS_UNDO_SENDSTOREKEY option to EMundo to force
                 EMundo to issue EMstore_key_from_id message.  Otherwise,
                 if overlap is detected on already undone node, then 
                 store key will fail because id has been removed/changed
                 due to undo.
    DLB 02/07/92 Check this node for ability to recompute.  External parents
                 may not have been able to recompute resulting in this node
                 becoming un-computable even thought it was able to unevaluate.
    DLB 01/31/92 Added reset of ORIENT_FLIPPED bit if no overlap found.
    DLB 09/05/91 Added env param to EMmatch.
    PP  08/10/91 Added support for adding/removing from rtree for
                 associativity. Specifically added EMeval_op_NO_ADD_TO_RT
                 and EMeval_op_NO_REMOVE_FROM_RT
    DLB 07/22/91 Support suppress object.  Before recomputing, construct and
                 connect on the child chan a suppress object.  Connect to it
                 the old in geom of this node.  If the compute succeeds then
                 delete this object.
    DLB 07/03/91 Set comp_inx to -1 if not found in dprparam list.  Then check
                 this before accessing.
    DLB 07/01/91 When a surface is geometrically modified, it is returned as
                 a replacing id in the outlist.  I modified the added_geom and
                 chg_id logic to support a returned replace_info structure
                 from EMgetOutInfo.
    DLB 06/26/91 Modified to better handle failures while in the graph update.
    DLB 05/20/91 Set this nodes ACTIVE_STATE bit to support error recovery.  
                 The idea here is to have the tree in a usage state for 
                 another compute pass.
    DLB 04/30/91 New params.
    DLB 04/14/91 EMputGetChangedId is now at EMSdprparam.
    DLB 03/29/91 Build construct list here and pass it to EMreexecute.
    DLB 03/15/91 If no overlap then reset compute_info->compute_id to
                 NULL_OBJID.  Otherwise, cleanup will attempt to clean the 
                 non-existent old info.
    DLB 02/20/91 Set NULL_STATE bit before recompute to handle failures better.
                 Also handle case of no old info.
    DLB 02/13/91 Reset mismatch tag array if at the top of the tree.
    DLB 02/12/91 Pass old and new geom ids to EMmatch method.
    DLB 01/16/91 Used param object instead of global EMS_compute_info struct.
    DLB 12/05/90 Move up EMputGetChangeIds before the EMresetssi send.  Also
                 getInGeomIds AFTER the reex for range check. Was using the old
                 in geom ids before this fix.
    DLB 11/19/90 Total rewrite to support localized recompute.  Necessary for
                 inter dependencies w/in the dpr tree.  MOST PARAMETERS WERE 
                 REMOVED!!!
    DLB 11/04/90 New 'added_geom' field is now in compute_info struct to
                 support local mods who add surfaces.  These surfaces will be
                 disconnected and stored in this struct for recovery purposes.
    DLB 09/28/90 Modified convert_to_cs to use get_edges rather than
                 count_edges.  Had to do this cause count_edges returns 
                 feature loop edges.
    DLB 09/04/90 Added EMmatch send to perform topology/geom matching.
    gupta Aug 08 90 : fixed a bug introduced while converting to 2.0
    DLB 02/04/90 Changed EMtoggleOrient sends to reflect the movement of this
                 msg up to EMSdpr.  Prior to this move, the send by this method
                 to anything other than a boolean class resulted in an unknown
                 msg and the invocation of the GRowner unknown msg handler.
    DLB 12/29/89 Added notify send specifically to update the xsection.
    DLB 11/18/89 No change but edited for ICOM check.
    DLB 11/15/89 Moved EMgetRI send from above EMreexecute send to below it.
    DLB 11/11/89 Added check for sl and stitchable edges or cs and
                 CONVERTED_TO_CS prop bit on.
    DLB 11/02/89 On 10/20 I added code to make node active before checking
                 overlap.  This logic is incorrect because a previous rc has
                 modified the topology.  Working on a better solution...
    DLB 11/01/89 Modified path following logic to see if sending down to the
                 replacement node. No need to send to the replacement node.
    DLB 10/20/89 Overlap checks should be done when the node is active.  So
                 I changed the logic to handle this.
    DLB 10/14/89 Added recovery code if a node is found that can't recompute.
    DLB 10/10/89 Fixed rng overlap code if replacing id had been removed
                 due to a disjoint case.
    DLB 10/08/89 Added num_path_ids, path_ids and curr_path_inx parameters.
    DLB 07/21/89 Added code to handle eval wrt new node.
    DLB 12/22/88 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            ii, jj, comp_inx = -1, num_chg_ids=0, num_compute_info=0;
  GRobjid           owner_id, *chg_ids=NULL, save_md_id;
  struct EMSinlist  inlist;
  struct EMSoutlist outlist;
  struct EMScompute_info *compute_info;
  IGRboolean        already_unevald=FALSE,/*when starting im already unevald*/
                    can_rc=TRUE,            /*im recomputable               */
                    converted_to_cs=FALSE,  /*true if CVRT_TO_CS bit set    */
                    no_old_info=FALSE,      /*is there old info to match    */
                    get_ri_info=FALSE,
                    world=TRUE,
                    no_overlap=FALSE,       /*if true no compute occurred   */
                    am_deleted=FALSE,
                    am_user_suppressed=FALSE,
                    am_macro_state=FALSE,
                    am_pattern_feature=FALSE,
                    recomp_failed=FALSE;
  void              EFcantrc();
  IGRushort         tmp_options, mask;
  OMuword           dumosnum;
  IGRint            num_added_geom_ids=0, new_num_added_geom_ids=0;
  GRobjid           *added_geom_ids=NULL, *new_added_geom_ids=NULL,
                    *loc_display_ids=NULL, param_id, const_info_id=NULL_OBJID,
                    suppress_id=NULL_OBJID;
  IGRint            loc_display_count=0;
  OM_S_CHANSELECT   to_comps, to_owners, to_children;
  OMuword           stat;
  extern IGRboolean EFisAncestryValid();
  IGRboolean	    SAVE_POST220_BEHAVIOR,
                    update_display_ids = FALSE;
  IGRshort	    grprops = NULL;        

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
  SAVE_POST220_BEHAVIOR = WANT_POST220_BEHAVIOR;

  /* Set the global flag indicating 240 behavior should take place or
     not. Pre 2.4 DPR nodes will be distinguished by the lack of this
     property. For an explanation of the property see
     $GRNUC/include/godef.h.
     SM 5/19/93.
  */
  (void) om$send(msg = message GRgraphics.GRgetprops(EMmsg, &grprops), 
         targetid = my_id);
  if(grprops & GRIS_POST220_OBJECT)
   WANT_POST220_BEHAVIOR = TRUE;
  else
    WANT_POST220_BEHAVIOR = FALSE;


  memset((char *) &outlist, '\0', sizeof(struct EMSoutlist));

  am_deleted = ME.EMSdpr->dpr_props & EMS_DELETED;
  am_user_suppressed = ME.EMSdpr->dpr_props & EMS_USER_SUPPRESSED;
  am_macro_state = ME.EMSdpr->dpr_props & EMS_MACRO_STATE;
  am_pattern_feature = ME.EMSdpr->dpr_props & EMS_PATTERN_FEATURE;

  EMmake_chanselect(GRconnector_to_owners, &to_owners);
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  /*Get the display_ids array*/
  OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(EMmsg,
                            &loc_display_count, &loc_display_ids, NULL),
                            my_id, OM_Gw_current_OS, &param_id, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

  update_display_ids = TRUE;

  OM_stat = om$send(msg = message EMSdprparam.EMgetStatus(EMmsg, &stat),
                    targetid = param_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  if (can_rc = !(stat & STAT_CANT_RECOMPUTE))
  {
    OM_stat = om$send(msg = message EMSdpr.EMcanRecompute(EMmsg, &can_rc),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (!can_rc)
    {
      EFcantrc(EMmsg, my_id, OM_Gw_current_OS);
    }
  }

  save_md_id = env->md_id.objid;

  if (!(ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH))
  {
    OM_stat = om$send(msg = message EMSdprparam.EMget_compute_info(EMmsg,
                            &num_compute_info, &compute_info, NULL),
                      targetid = param_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

    /*Find my index in the array*/
    for (comp_inx=0; comp_inx<num_compute_info; comp_inx++)
    {
      if (compute_info[comp_inx].computed_id == my_id) break;
    }
    if (comp_inx == num_compute_info) comp_inx = -1;
  }

  /*Get the suppress id if it already exists*/
  EMmake_chanselect(NDchildren_children, &to_children);
  OM_stat = om$send(msg = message EMSsuppress.EMget_suppress_id(EMmsg,
                          &suppress_id, NULL),
                    p_chanselect = &to_children);
  if (!(1 & OM_stat & *EMmsg) && (OM_stat!=OM_W_UNKNOWN_MSG)) goto wrapup;
  OM_stat = OM_S_SUCCESS;

  if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE) &&
      !(ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH))
  {
    ex$message(msgnumb = EMS_I_NoOverlapSkip)
#   if DEBUG
    fprintf(stderr,"no overlap found on node %d (%s)\n", my_id, my_name);
#   endif

    if (comp_inx != -1)
    {
      extern OMuword    OPP_EMSsfboolfea_class_id;

      /*I passed all the tests so just reactivate me.*/
      if (suppress_id != NULL_OBJID)
      {
        OM_stat = om$send(msg = message EMSsuppress.EMmove_comps(EMmsg,
                                my_id, FALSE,
                                NULL, NULL, NULL),
                          targetid = suppress_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;

        OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                          targetid = suppress_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;                          
      }

      OM_stat = om$send(msg = message EMSdpr.EMconnectTopology(EMmsg,
                              &compute_info[comp_inx].con_top, NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      tmp_options = (options & EMeval_op_DO_DISPLAY ? EMS_DO_DISPLAY : NULL);
      OM_stat = om$send(msg = message EMSdpr.EMactivate(EMmsg,
                              (IGRshort *) &tmp_options, env,
                              &loc_display_ids, &loc_display_count),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                            OPP_EMSsfboolfea_class_id, FALSE))
      {
        /*See if all the components were added to the ids list, if not
         * add'em       TR 119301118
         */ 
        OMuint  fea_comp_cnt;
        GRobjid fea_comp_id;

        OM_stat = om$get_channel_count(object = me,
                                       p_chanselect = &to_comps,
                                       count = &fea_comp_cnt);
        if (!(1 & OM_stat)) goto wrapup;

        for(ii=1; ii<fea_comp_cnt; ii++)
        {
          OM_stat = om$get_objid_at_index(object = me,
                                          p_chanselect = &to_comps,
                                          index = ii,
                                          objidaddr = &fea_comp_id,
                                          osnumaddr = &dumosnum);
          if (!(1 & OM_stat)) goto wrapup;

          /*Has this surface already been erased?*/
          for (jj=0; jj<loc_display_count; jj++)
          {
            if (loc_display_ids[jj] == fea_comp_id) break;
          }

          if (jj == loc_display_count)
          {
            /*Wasn't there*/ 
            EFrealloc_if_needed(EMmsg, &loc_display_ids, loc_display_count, 
                                DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
            if (!(1 & *EMmsg)) goto wrapup;
 
            loc_display_ids[loc_display_count] = fea_comp_id;
            loc_display_count++;
          }
        }
      } /*End TR 119301118*/

      compute_info[comp_inx].computed_id = NULL_OBJID; /*DLB 3/15/91*/
    }
    ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_PATH | EMSIS_ACTIVE_STATE);
    ME.EMSdpr->dpr_props &= ~EMS_ORIENT_FLIPPED;

    converted_to_cs = ME.EMSdpr->dpr_props & EMS_CONVERTED_TO_CS;

    no_overlap = TRUE;
  }
  else if (ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)
  {
#   if DEBUG
    fprintf(stderr,"Evaluating node %d (%s)\n", my_id, my_name);
#   endif    

    already_unevald = TRUE;

    converted_to_cs = ME.EMSdpr->dpr_props & EMS_CONVERTED_TO_CS;
    
    /*NOTE:  Need to only do EMundo if ! DONT_CHECK_DEPENDENTS. I'll change it
     *       later.
     *
     * 2/25/92 - Only go into undo code if I can recompute.  A waste otherwise.
     */
    if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH && can_rc)
    {
      IGRint invoke_count=0;

      tmp_options = EMS_UNDO_SAVE | 
                    EMS_DO_DISPLAY | EMS_DONT_REDRAW |
                    EMS_DISCONNECT_TOP | 
                    EMS_UNDO_SENDSTOREKEY; 
      OM_stat = om$send(msg = message EMSdpr.EMundo(EMmsg, &tmp_options, env,
                              NULL, NULL, NULL, &loc_display_ids,
                              &loc_display_count, &invoke_count),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      OM_stat = om$send(msg = message EMSdprparam.EMget_compute_info(EMmsg,
                              &num_compute_info, &compute_info, NULL),
                        targetid = param_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

      /*Again find my index in the array*/
      for (comp_inx=0; comp_inx<num_compute_info; comp_inx++)
      {
        if (compute_info[comp_inx].computed_id == my_id) break;
      }
      if (comp_inx == num_compute_info) comp_inx = -1;
    }

    if (!(options & EMeval_DONT_CHECK_DEPENDENTS))
    {
      /*Get the changed ids for processing.*/
      OM_stat = om$send(msg = message EMSdprparam.EMputGetChangedId(EMmsg,
                              &num_chg_ids, &chg_ids, NULL),
                        targetid = param_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;               

      if (num_chg_ids)
      {
        /*Delete'em all now.*/
        OM_stat = om$send(msg = message EMSdprparam.EMputGetChangedId(EMmsg, 0,
                                NULL, EMputGetChangedId_DELETE),
                        targetid = param_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;               
      }
    }

    /*Do it!*/
    if (!(ME.EMSdpr->dpr_props & EMS_NULL_STATE))
    {
     if(comp_inx != -1)
     {
      OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, 
                              &(compute_info)[comp_inx].ssi),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
     }

      /*MOVED EMgetRI FROM HERE TO AFTER REEX.*/
      get_ri_info = TRUE;

      /*Get added geom (if any, localmods), record ids & indices to me,
       * then remove'em.
       */
      OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg,
                              NULL_OBJID, FALSE,
                              &num_added_geom_ids,  
                              &added_geom_ids, NULL),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (num_added_geom_ids)
      {
        /*Create the new suppress id and connect it up*/
        OM_stat = EFcreate_suppress_id(EMmsg, my_id, OM_Gw_current_OS, 
                                       &suppress_id, NULL);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;      

        OM_stat = om$send(msg = message EMSsuppress.EMmove_comps(EMmsg,
                                my_id, TRUE,
                                num_added_geom_ids, added_geom_ids, NULL),
                          targetid = suppress_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;

        const_info_id = added_geom_ids[0];
      }

      OM_stat = om$send(msg = message EMSdpr.EMresetSSI(EMmsg),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                          

      ME.EMSdpr->dpr_props |= EMS_NULL_STATE;
    }
    else if (suppress_id != NULL_OBJID)
    {
      /*Extract the old added geom from the suppress object.*/
      OM_stat = om$send(msg = message EMSsuppress.EMget_suppressed_geom(EMmsg,
                              &num_added_geom_ids,
                              &added_geom_ids,
                              NULL),
                        targetid = suppress_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
    else no_old_info = TRUE;

    /*WARNING!  As noted above, care must be taken with the pointer to the
     * items in the EMSdprparam object since a callee might overwrite
     * the callers array.  Although the EMreexecute message has the display ids
     * as parameters, most overrides dont support the display ids as
     * parameters.  Due to this, the display_ids array will be put before the
     * EMreexecute is sent.
     */
    if (loc_display_count)
    {
      OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                              loc_display_count, loc_display_ids, NULL),
                        targetid = param_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                         
      loc_display_count = 0;
      loc_display_ids = NULL;
      update_display_ids = FALSE;
    }

    if (can_rc)
    {
      /*Recompute me.*/
      ex$message(msgnumb = EMS_I_RecompNode)

      if (!am_deleted && !am_user_suppressed)
      {
        struct GRvg_construct construct_list;
        struct GRsymbology    symb;
        struct IGResbs        element_specific;
      
        construct_list.msg = EMmsg;
        construct_list.display = &symb.display_attr;
        construct_list.env_info = env;
        construct_list.class_attr = (IGRchar *) &element_specific;
  
        OM_stat = EFget_construction_info_from_id(EMmsg, &construct_list,
                                                (const_info_id == NULL_OBJID ? 
                                                 my_id : const_info_id),
                                                 OM_Gw_current_OS);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
        construct_list.properties &= ~GR_RIGID_RELATIONSHIP;
        construct_list.newflag = FALSE;
  
        tmp_options = NULL;
        OM_stat = om$send(msg = message EMSdpr.EMreexecute(EMmsg, &tmp_options,
                                env, parent_count, parent_list,
                                type, recomp_info,
                                &construct_list),
                          targetid = my_id);
  
        if (am_macro_state) ME.EMSdpr->dpr_props |= EMS_MACRO_STATE;
        if (am_pattern_feature) ME.EMSdpr->dpr_props |= EMS_PATTERN_FEATURE;
      }
      else ME.EMSdpr->dpr_props |= (EMSIS_ACTIVE_PATH | EMSIS_ACTIVE_STATE);

      { /*INTENTIONAL BLOCK*/
        IGRlong loc_msg, loc_stat;
        loc_stat = om$send(msg = message EMSdprparam.EMget_display_ids(
                                 &loc_msg, &loc_display_count,
                                 &loc_display_ids, NULL), 
                           targetid = param_id);
        if (!(1 & loc_stat & loc_msg)) goto wrapup;                         

        update_display_ids = TRUE;
      }

      if ((1 & OM_stat & *EMmsg) && *EMmsg != EMS_I_Fail 
          && !am_deleted && !am_user_suppressed)  
      {
        /*IT WORKED!*/
        ME.EMSdpr->dpr_props &= ~(EMS_UNEVAL_STATE | EMS_NULL_STATE);

        /*Get the new added geom ids for matching/next states overlap check.*/
        OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg,
                                NULL_OBJID, FALSE,
                                &new_num_added_geom_ids,  
                                &new_added_geom_ids, NULL),
                          targetid = my_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      
        for(ii=0; ii<new_num_added_geom_ids; ii++)
        {
          EFrealloc_if_needed(EMmsg, &loc_display_ids, loc_display_count, 
                              DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
          if (!(1 & *EMmsg)) goto wrapup;

          loc_display_ids[loc_display_count] = new_added_geom_ids[ii];
          loc_display_count++;

/*
 * If the option has been specified to not add the recomputed object to
 * the rtree then remove the same from the rtree. There is scope for
 * this to be a little more efficient. But I am trying to make the minimum
 * change necessary for the thing to work.
 * pp 08/10/91

 * If the option does not specify removal from the Rtree then post the reduced
 * range of the newly created surfaces into the Rtree.
 * SM/SAM 01/27/93
 */
          if ((options & EMeval_op_NO_ADD_TO_RT) &&
              (save_md_id != NULL_OBJID))
          {
           env->md_id.objid = NULL_OBJID;
           OM_stat = om$send (msg = message GRgraphics.GRremwrng(EMmsg,
                                   env),
                              targetid= new_added_geom_ids[ii]);
           env->md_id.objid = save_md_id;
/*i end pp */
           if (!(1 & OM_stat & *EMmsg)) goto wrapup;
          }
          else if (!(options & EMeval_op_NO_ADD_TO_RT) &&
              (save_md_id != NULL_OBJID))
           {
            IGRuchar sfchange = GEOMETRICAL;
            IGRlong rc;

/*
 *	    The property EMSIS_RTREE_RANGE_GOOD should be internally 
 *	    used only --vidya 10/06/93
            IGRuchar sfchange = TOPOLOGICAL;
            (void) om$send(msg = message EMSsubbs.EMset_props(&rc, 
                   EMSIS_RTREE_RANGE_GOOD, EMS_O_OFF), 
                   targetid = new_added_geom_ids[ii]);
 */
            (void) om$send(msg = message EMSsubbs.EMput_range_in_rtree(&rc, 
                   NULL, NULL, NULL, sfchange, &env->md_id), 
                   targetid = new_added_geom_ids[ii]);

           }
        } 

        if (! no_old_info)
        {
          /*Perform topology matching - DLB 9/04/90.
           * The ssi param may be NULL if an overlap existed during the uneval
           * uneval phase.  The EMmatch targets should process added geom if
           * it exists and should check for a valid ssi param before
           * processing - DLB 7/22/91.
           */
          OM_stat = om$send(msg = message EMSdpr.EMmatch(EMmsg,
                                  (comp_inx == -1 ? NULL : 
                                                   compute_info[comp_inx].ssi),
                                  num_added_geom_ids,
                                  added_geom_ids,
                                  new_num_added_geom_ids,
                                  new_added_geom_ids,
                                  NULL,
                                  env),
                            targetid = my_id);
#         if DEBUG
          if (!(1 & OM_stat & *EMmsg))
          {
            fprintf(stderr,"WARNING: Error in EMmatch node %d (%s)\n",
                    my_id, my_name);
            EFprintcode(0, OM_stat);
            EFprintcode(0, *EMmsg);            
          }
#         endif
        }
        else
        {
#         if DEBUG
          fprintf(stderr,"WARNING: Not matching node %d (%s), no old info\n",
                  my_id, my_name);
#         endif
        }
  
        if (suppress_id != NULL_OBJID)
        {
          /*Remove the old EMSsuppress object*/

/*
 * If the old geometry should not be removed from the rtree then set
 * the module id to be NULL_OBJID and reset it back after the delete.
 * pp 08/10/91
 */
          if ((options & EMeval_op_NO_REMOVE_FROM_RT) &&
              (save_md_id != NULL_OBJID))
           env->md_id.objid = NULL_OBJID;

          OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                            targetid = suppress_id);
          env->md_id.objid = save_md_id;

          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }                            

        if (!(options & EMeval_DONT_CHECK_DEPENDENTS))
        {
          IGRint tmp_cnt=0;

          /*Get the outinfo for next states overlap check.*/
  
          memset((char *) &inlist, '\0', sizeof(struct EMSinlist));
          inlist.modlist.mod_id = NULL_OBJID;

          outlist.rnglist.num_repl_info = 0;
          outlist.rnglist.replace_info = NULL;

          /*In certain situations EMgetOutInfo may return a replace id if there
           * was a geometric modification.
           */
          OM_stat = om$send(msg = message EMSdpr.EMgetOutInfo(EMmsg, &outlist,
                                  NULL),
                            targetid = my_id);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
          /*Store the new added surfs or modified surfs of changed ids for the
           * next state overlap pass (if any).
           */

          tmp_cnt = new_num_added_geom_ids + num_chg_ids;
  
          if (tmp_cnt || outlist.rnglist.num_repl_info)
          {
            if (outlist.rnglist.num_repl_info)
            {
              tmp_cnt += outlist.rnglist.num_repl_info;
              outlist.rnglist.replace_info = (struct EMSreplace_info *)
                   om$realloc(ptr = (IGRchar *) outlist.rnglist.replace_info,
                              size = tmp_cnt * sizeof(struct EMSreplace_info));
            }
            else
            {
              outlist.rnglist.replace_info = (struct EMSreplace_info *)
                    om$malloc(size = tmp_cnt * sizeof(struct EMSreplace_info));
            
            }
            if (! outlist.rnglist.replace_info)
            {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
          
            jj = outlist.rnglist.num_repl_info;

            for(ii=0; ii<new_num_added_geom_ids; ii++, jj++)
            {
              outlist.rnglist.replace_info[jj].replacing_id =
                                                        new_added_geom_ids[ii];
            }
    
            for(ii=0; ii<num_chg_ids; ii++, jj++)
            {
              outlist.rnglist.replace_info[jj].replacing_id = chg_ids[ii];
            }
    
            outlist.rnglist.num_repl_info = tmp_cnt;

            for(ii=0; ii<outlist.rnglist.num_repl_info; ii++)
            {
              OM_stat = om$send(msg = message GRgraphics.GRgetrang(EMmsg,
                                      &env->md_env.matrix_type,   
                                      env->md_env.matrix,  
                                      &world, 
                                      outlist.rnglist.replace_info[ii].range),
                     targetid = outlist.rnglist.replace_info[ii].replacing_id);
              if (!(1 & OM_stat & *EMmsg)) goto wrapup;
            }
          }
  
          OM_stat = om$send(msg = message EMSdpr.EMcheckDPROverlap(EMmsg,
                                  &inlist, &outlist, env, NULL),
                            p_chanselect = &to_owners);
          if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG))
            goto wrapup;                                 
  
          OM_stat = OM_S_SUCCESS;
  
          if (*EMmsg == EMS_I_CantRecompute)
          {
            can_rc = FALSE;
          }
        }

        if (converted_to_cs) ME.EMSdpr->dpr_props |= EMS_CONVERTED_TO_CS;
 
        if (get_ri_info)
        {
          /*If applicable, get the recompute info. Note that this may not get
           * get anything.
           */
          if(comp_inx != -1)
           om$send(msg = message EMSdpr.EMgetRI(EMmsg, 
                        &(compute_info)[comp_inx].ri),
                  targetid = my_id);
          /*Ignore return codes since some operations will not have RI stuff 
           * and the message will either be unknown or rejected.
           */
        }

        if (!can_rc)
        {
          OM_stat = om$send(msg = message EMSdpr.EMrecover(EMmsg,
                                  num_compute_info, compute_info, 
                                  env, NULL),
                            targetid = my_id);
          if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG))
            goto wrapup;
          else OM_stat = OM_S_SUCCESS;
  
          /*Set the status in the param object to CANT_RECOMPUTE*/
          OM_stat = om$send(msg = message EMSdprparam.EMsetStatus(EMmsg,
                                  FALSE, STAT_CANT_RECOMPUTE),
                            targetid = param_id);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }
      }
      else
      {
        /*Note:  At this point the old ssi should be put back to match
         *  purposes.  This is somewhat vague at this point (e.g. what about
         *  added surfs) so  I'll leave it be.
         */

        if (am_deleted)
        {
#         if DEBUG
            fprintf(stderr,
                  "node %d (%s) is deleted... skipping\n", my_id, my_name);

#         endif      
        }
        else if (am_user_suppressed)
        {
#         if DEBUG
          fprintf(stderr,  "node %d (%s) is user suppressed... skipping\n", 
                  my_id, my_name);
#         endif      
        }
        else
        {
#         if DEBUG
          fprintf(stderr,"RECOMPUTE FAILURE!! node %d (%s)\n", my_id, my_name);
#         endif      
          recomp_failed = TRUE;          
        }
      }
    }
  }
  else  
  {
    ex$message(msgnumb = EMS_I_NoOverlapSkip)
#   if DEBUG
      fprintf(stderr,"Skipping node %d (%s)\n", my_id, my_name);
#   endif    

    if (ME.EMSdpr->dpr_props & EMS_ORIENT_FLIPPED)
    {
      OM_stat = om$send(msg = message EMSdpr.EMtoggleOrient(EMmsg, NULL),
                        targetid = my_id);
      ME.EMSdpr->dpr_props &= ~EMS_ORIENT_FLIPPED;
    }

    no_overlap = TRUE;
  }

  if (no_overlap)
  {
     IGRlong loc_msg=EMS_S_Success, loc_stat;
     /*
      * calling notify listeners so that my_id's tag is incremented and
      *  listeners are notified.
      *  - copied from EAsfdcomp.I 2/13/92 - DLB
      */
     GR_NOTIFY_LISTENERS(&loc_msg, &loc_stat, GR_GEOM_MODIFIED);
     om$send(msg = message EMSpointerA.EMstore_id_from_key(&loc_msg, NULL,
                   NULL), 
             p_chanselect = &to_children);
  }

  { /*INTENTIONAL*/
    /*Turn off last states ACTIVE_STATE bit since this node might have been
     * undone via the EMundo message
     */
    IGRboolean action=FALSE;

    mask = EMSIS_ACTIVE_STATE;

    OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action,
                            (IGRushort *) &mask),
                      p_chanselect = &to_comps);
    if(!(1 & *EMmsg & OM_stat) && (OM_stat != OM_W_UNKNOWN_MSG))goto wrapup;
   
    OM_stat = OM_S_SUCCESS;
  }

  if (loc_display_count)
  {
    OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                            loc_display_count, loc_display_ids, NULL),
                      targetid = param_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                         

    update_display_ids = FALSE;
  }

  /*Lastly need to determine the proper setting of the ACTIVE_STATE
   * bit.  Do this by seeing if I have ANY DPR owner.  If so then I can
   * turn mine off.  
   * Previously the onwer was check to see if it was in the active path.
   * The advent of undoing to check for overlap invalidated this logic.
   */

  /*Now go on and turn my ACTIVE_STATE bit on to support error recovery.*/
  ME.EMSdpr->dpr_props |= EMSIS_ACTIVE_STATE;

  OM_stat = om$get_objid_at_index(object = me,
                                  p_chanselect = &to_owners,
                                  index = 0,
                                  objidaddr= &owner_id,
                                  osnumaddr = &dumosnum);
  if (!(1 & OM_stat) || !EFisAncestryValid(EMmsg, owner_id, OM_Gw_current_OS, 
                                           OPP_EMSdpr_class_id, FALSE))
  {
    /*No owner or owners not a dpr so this is the real active state (i.e. top
     * state)
     */ 
    OM_stat = OM_S_SUCCESS;

#   if DEBUG
      fprintf(stderr,"Removing tags from mismatch list\n");
#   endif    

    EFremove_all_tags();  /*Should I do this now??*/

    if (num_compute_info && compute_info)
    {
      /*Tree computed successfully; clean up the compute info*/

#     if DEBUG
        fprintf(stderr,"Cleaning up compute info\n");
#     endif    

      OM_stat = om$send(msg = message EMSdpr.EMcleanupComputeInfo(EMmsg, 
                              NULL, env, num_compute_info,
                              compute_info),
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    OM_stat = om$send(msg = message EMSdprparam.EMdisplay(EMmsg, env,
                            NULL), 
                      targetid = param_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

#   if DEBUG
      fprintf(stderr,"Deleting param object\n");
#   endif    

    OM_stat = om$send(msg = message EMSdprparam.EMdelete(EMmsg, NULL),
                      targetid = param_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if (can_rc)
  {
    IGRboolean conversion_occurred=FALSE, action;
    void EFconvert_to_cs(), EFconvert_to_sl();

    /*Attempt to convert to CS or SL depending on bits and stitchable edges*/ 
    if (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                          OPP_EMSsolid_class_id, FALSE))
    {
      EFconvert_to_cs(EMmsg, my_id, OM_Gw_current_OS, env, NULL);
      if (!(1 & *EMmsg)) goto wrapup;

      if (*EMmsg == EMS_I_ChangeClass)
      {
        /*Conversion occured so set the bit.*/
        conversion_occurred = TRUE;
        action = TRUE;

#       if DEBUG
        fprintf(stderr,"Node %d (%s) converted to cs\n", my_id, my_name);    
#       endif    
      }
    }
    else if (converted_to_cs)
    {
      EFconvert_to_sl(EMmsg, my_id, OM_Gw_current_OS, env, NULL);
      if (!(1 & *EMmsg)) goto wrapup;
      
      if (*EMmsg == EMS_I_ChangeClass)
      {
        /*Conversion occured so reset the bit.*/
        conversion_occurred = TRUE;
        action = FALSE;
#       if DEBUG
        fprintf(stderr,"Node %d (%s) converted to sl\n", my_id, my_name);    
#       endif    
      }
    }

    if (conversion_occurred)
    {
      /*IMPORTANT - I have just changed class so DO NOT access instance data
       *            directly.
       */
      mask = EMS_CONVERTED_TO_CS;
      OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action,
                              &mask),  
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  if (!can_rc) *EMmsg = EMS_I_CantRecompute;

  wrapup:

    /* post the display_ids to the EMSdprparam object if necessary */

    if (update_display_ids && loc_display_count)
    {
      OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                                   loc_display_count, loc_display_ids, NULL),
                        targetid = param_id);
    }

    ex$message(msgnumb = EMS_I_ClearStatusField)
    if (chg_ids) om$dealloc(ptr = chg_ids);
    if (outlist.rnglist.replace_info) om$dealloc
                                      (ptr = outlist.rnglist.replace_info);
    if (outlist.lplist.loop_ids) om$dealloc
                                      (ptr = outlist.lplist.loop_ids);
    if (outlist.sfmodlist.surf_ids) om$dealloc
                                      (ptr = outlist.sfmodlist.surf_ids);
    if (outlist.sflist.surf_ids) om$dealloc
                                      (ptr = outlist.sflist.surf_ids);
    if (outlist.edlist.edge_ids) om$dealloc
                                      (ptr = outlist.edlist.edge_ids);
    if (added_geom_ids) om$dealloc(ptr = added_geom_ids);
    if (new_added_geom_ids) om$dealloc(ptr = new_added_geom_ids);

    WANT_POST220_BEHAVIOR = SAVE_POST220_BEHAVIOR;

    EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMevaluateOps")
    if (recomp_failed) *EMmsg = ND_COMP_FAIL;
    else               *EMmsg = ND_COMP_SUCC;
    return(OM_stat);
}

#ifdef __STDC__
#argsused
#endif
void EFconvert_to_cs(EMmsg, sl_id, sl_os, env, options)
IGRlong           *EMmsg;
GRobjid           sl_id;
OMuword           sl_os;
struct GRmd_env   *env;
IGRushort options;
{
  IGRlong    OM_stat=OM_S_SUCCESS;
  IGRboolean stitchable;

  *EMmsg = EMS_S_Success;

  /*First see if there are any stitchable edges.*/
  stitchable = EFcomp_stitchable(EMmsg, sl_id, sl_os, env, NULL, NULL);
  if (!(1 & *EMmsg)) goto wrapup;

  if (stitchable) 
  {
    OMuword sl_classid;
    IGRchar p_classname[OM_K_MAXCLASS_LEN];
    extern IGRboolean EFisAncestryValid();
    extern OMuword    OPP_EMSsfboolfea_class_id;

    if (!EFisAncestryValid(EMmsg, sl_id, sl_os, OPP_EMSsfboolfea_class_id,
                           FALSE))
    {
      /*Get the proper composite surface class to change the solid to.*/
      OM_stat = om$get_classid(objid = sl_id,
                               osnum = sl_os,
                               p_classid = &sl_classid);
      if (!(1 & OM_stat)) goto wrapup;
    
      OM_stat = om$get_parent_classname(classid = sl_classid,
                                        parent_classname = p_classname);
    }
    else
    {
      /*Handle special case of boolfea*/
      struct GRid src_grid;

      strcpy(p_classname, "EMSsfboolean");

      /*Move me to root*/
      OM_stat = om$send(msg = message NDnode.NDmove_to_root(EMmsg, &src_grid,
                              env),
                        senderid = NULL_OBJID,
                        targetid = sl_id,
                        targetos = sl_os);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                          
    }

    /*Convert the solid to composite surface (or comp surf DPR).*/
    OM_stat = om$change_class(objid = sl_id,
                              osnum = sl_os,
                              classname = p_classname,
                              sd_override = OM_K_change_class_sd_override);
    if (!(1 & OM_stat)) goto wrapup;

    *EMmsg = EMS_I_ChangeClass;
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFconvert_to_cs")
    return;
}  

#ifdef __STDC__
#argsused
#endif
void EFconvert_to_sl(EMmsg, cs_id, cs_os, env, options)
IGRlong           *EMmsg;
GRobjid           cs_id;
OMuword           cs_os;
struct GRmd_env   *env;
IGRushort options;
{
  IGRlong    OM_stat=OM_S_SUCCESS;
  IGRboolean stitchable;


  *EMmsg = EMS_S_Success;

  /*First see if there are any stitchable edges.*/
  stitchable = EFcomp_stitchable(EMmsg, cs_id, cs_os, env, NULL, NULL);
  if (!(1 & *EMmsg)) goto wrapup;

  if (!stitchable)
  {
    IGRchar c_classname[OM_K_MAXCLASS_LEN];

    OM_stat = om$send(msg = message EMSsfdpr.EMgetsolidclass(EMmsg, 
                            c_classname),
                      senderid = NULL_OBJID,
                      targetid = cs_id,
                      targetos = cs_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*Convert the solid to composite surface (or comp surf DPR).*/
    OM_stat = om$change_class(objid = cs_id,
                              osnum = cs_os,
                              classname = c_classname,
                              sd_override = OM_K_change_class_sd_override);
    if (!(1 & OM_stat)) goto wrapup;

    *EMmsg = EMS_I_ChangeClass;
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EFconvert_to_sl")
    return;
}  
end implementation EMSdpr;



#if SUPPORTING_SHELLING_OF_DPR_NODES
    /*Handle the shells (if any).*/
    /*Get all of the components.*/
    shell_GRid = NULL;
    
    EFgetobjids(EMmsg, &my_GRid, &DIowner$to_members_chanselect, &shell_GRid,
                &num_shell_GRids, 
                OPP_EMSsfeditmgr_class_id, NULL, NULL);
    if (!(1 & *EMmsg)) goto wrapup;
    
    if (options & EMeval_op_EVAL_ALL_SHELLED) perform_eval = TRUE;
    else
    {
      if (num_shell_GRids)
      {
        /*I have a shell, continue processing...*/
        if (options & EMeval_op_EVAL_GIVEN_SHELLED)
        {
          /*See if all of my shells are in the shell list.*/
          for(ii=0; ii<num_shell_GRids; ii++)
          {
            for(jj=0; jj<num_to_eval; jj++)
            {
              if (shell_GRid[ii].objid == eval_ids[jj]) break;
            }
            if (jj == num_to_eval) break;
          }
          if (ii < num_shell_GRids) perform_eval = TRUE;
        }
      }      
      else if (options & EMeval_op_EVAL_ALL_NONSHELLED) perform_eval = TRUE;
    }

    /*Evaluate this baby!!*/
    if(num_shell_GRids)
    {
      /*Blow away the shells.*/
      /*Allocate the array for indices array for comp_ids.*/
      to_comp_index = (IGRint *) om$malloc
                      (size = num_shell_GRids * sizeof(IGRint));
      if (!to_comp_index) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
      comp_id = (GRobjid *) om$malloc
                (size = num_shell_GRids * sizeof(GRobjid));
      if (!comp_id) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

      for(ii=0; ii<num_shell_GRids; ii++)
      {
        /*Remove the shells and connect their component nodes to me.*/
        /*Remember the channel index to my component.*/
        OM_stat = om$get_index(object_c = Root,
                               p_chanselect = &DIowner$to_members_chanselect,
                               objid = shell_GRid[ii].objid,
                               indexaddr = &to_comp_index[ii]);
        if (!(1 & OM_stat)) goto wrapup;
        /*Get the component id owned by the shell.*/
        OM_stat = om$get_objid_at_index(objid = shell_GRid[ii].objid,
                                 p_chanselect = &DIowner$to_members_chanselect,
                                 index = 0,
                                 objidaddr = &comp_id[ii],
                                 osnumaddr = &dumosnum);
        if (!(1 & OM_stat)) goto wrapup;
        /*Remove the component from the shell.*/
        OM_stat = om$send(msg = DImember$DIrm(EMmsg,
                                NULL, NULL_INDEX,
                                &shell_GRid[ii]), 
                          targetid = comp_id[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        /*Remove the shell from me.*/
        OM_stat = om$send(msg = DImember$DIrm(EMmsg,
                                NULL, NULL_INDEX,
                                &my_GRid),
                          targetid = shell_GRid[ii].objid);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        /*Connect the component to me at the proper index.*/

        OM_stat = om$send(msg = DImember$DIadd(EMmsg,
                                NULL, 
                                &my_GRid, 
                                to_comp_index[ii],
                                NULL),
                          targetid = comp_id[ii]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }


     /*Successful reex. Delete all those shells, if any*/
     for(ii=0; ii<num_shell_GRids; ii++)
     {
       OM_stat = om$send(msg =  Root$delete(NULL),
                         targetid = shell_GRid[ii]);
       if (!(1 & OM_stat)) goto wrapup;
     }

     /*A failure occurred.  Put the shells back in place, if any.*/
     for(ii=0; ii<num_shell_GRids; ii++)
        {
          /*Disconnect the component from me.*/
          OM_stat = om$send(msg = DImember$DIrm(EMmsg,
                                  NULL, NULL_INDEX,
                                  &my_GRid),
                            targetid = comp_id[ii]);

          if (!(1 & OM_stat & *EMmsg)) goto wrapup;

          /*Connect it back to the shell.*/
          OM_stat = om$send(msg = DImember$DIadd(EMmsg,
                                  NULL,
                                  &shell_GRid[ii],
                                  inx,
                                  NULL),
                            targetid = comp_id[ii]);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;

          /*Connect the shell back to me.*/
          OM_stat = om$send(msg = DImember$DIadd(EMmsg,
                                  NULL, 
                                  &my_GRid,
                                  to_comp_index[ii],
                                  NULL),
                            targetid = shell_GRid[ii]);

          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }
      }
#endif
