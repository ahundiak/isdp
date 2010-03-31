/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include <alloca.h>
#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSprop.h"
#include "memory.h"
#include "emsdef.h"

# include "exdef.h"
# include "exmacros.h"

#include "PWminimum.h"
#include "PWapi/sfcompsf.h"

#define  SF_INCR 6

%safe
static void UpdateSurfaceRtreeRange
(
  PWobjid sfobj,
  PWosnum os,
  struct GRid *md_grid
);
%endsafe

from EMSdpr import EMdeactivateState, EMremoveOpnd, EMsetprops,
                   EMaddManager, EMcorrectOrient;
from EMSsubbs import EMput_range_in_rtree;

method EMunevaluate(IGRlong           *EMmsg;
                    IGRushort options; 
                    struct   GRmd_env *env; 
                    GRobjid           **display_ids; 
                    IGRint            *display_count; 
                    GRobjid           *active_id, nodes_owner_id, *batch_id)
/*
Description
    This message will unevaluate a node in the DPR tree.

Return Values
    EMSS_S_Success if all is well.

Notes
    About parameters:
      options:
        EMuneval_REMOVE_UNEVAL_NODES - remove the unevaluated node from the
                                       tree. 
                                  This option is mutually exclusive wrt the
                                  IMMEDIATE_OPER option.
        EMuneval_ADD_MANAGER - xor with EMuneval_REMOVE_UNEVAL_NODES option.
                If set manager objects will be added to all unevaluated nodes.
        EMuneval_DO_DISPLAY - Perform efficient internal display.
        EMuneval_DONT_REDRAW - Don't redraw surfaces.  Instead, return then to
                               the sender.
        EMuneval_DELETE_SSI - Delete the the SSI info.
        EMuneval_IMMEDIATE_OPER - Unevalute this operation only rather than 
                                  the entire limb of the tree.
                                  This option is mutually exclusive wrt the
                                  REMOVE_UNEVAL_NODES option.
      display_ids - Contains the surfaces erased if options is
                    EMuneval_DO_DISPLAY AND EMuneval_DONT_REDRAW.  Sender
                    should set pointer to NULL. 
      display_count - Number of surfaces in above array.  Sender should set
                      parameter to 0.
      active_id - The active state id after the unevaluation occurs.  This
                  may be the same as before the uneval.                    
      nodes_owner_id - If the node to unevaluate is removed due to disjoint 
                       case then is param MUST NOT be NULL_OBJID otherwise it
                       must be NULL_OBJID.  It is obviously assumed that the
                       sender will know this.
      batch_id - (OPTIONAL) returned indicating id to throw on batch for
                 recompute.  Will be my owner id but can be different if option
                 to remove uneval'd node.  May also be NULL_OBJID if tree 
                 disappeared.
       
    About reevaluation:
      Reevaluation should be performed by putting a tree node on the batch.


    If display_ids is returned, the sender should dealloc the array by
      the om$dealloc macro.
      
History
 Sanjay 12/05/95 Update the R-tree range for the component surface objects 
                 of the input object after restoring the original operands
                 (OR deactivating the present state), so that the R-tree 
                 range always corresponds to the present topology of the 
                 surface. Fix for TR# 119528382.
    DLB 01/31/92 Removed crazy correctOrient sends which were never correct.
    DLB 06/27/91 My wonderous revelation on 11/08 is only true if unevaluating
                 the immediate operation. Otherwise, I still need to get the
                 geom and topology for the limb being uneval'd.
    DLB 11/27/90 Use memset to init EMSinlist.
    DLB 11/08/90 A wonderous revelation appeared to me that this method need
                 not get info about the node being unevaluated since this will
                 be gotten by the EMdeactivateStat message.
    DLB 11/05/90 Modified Sunits change to once again get the surfaces from
                 this node directly.  A local mod operation will have surfaces,
                 edges, & loops that it created.  The idea here is to get the
                 surfs/loops/edges this node CREATED.
    SM  08/02/90 Get surfs/loops/edges only for primitives and leaf
                 surfs. Also ignore UNKNOWN_MSG after any send to the owner.
    SM  07/13/90 If EMuneval_IMMEDIATE_OPER
                 get in info and send deactivate state to myself.
    DLB 11/07/89 Added owner_id param for cases where the node to unevaluate 
                 has been removed due to disjoint case.
    DLB 09/04/89 Added loops and edges of surfs to inlist.
    DLB 12/07/88 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS, save_msg;
  IGRint            ii;
  GRobjid           my_owner_id;
  GRobjid           *surf_list=NULL;
  struct GRid       active_GRid;
  struct EMSinlist  inlist;
  IGRushort flags, deact_options;
  OMuword           dumosnum;


  *EMmsg = EMS_S_Success;

  /*Start out with empty buffers.*/
  memset((char *) &inlist, '\0', sizeof(struct EMSinlist));
  inlist.modlist.mod_id = NULL_OBJID;

  *active_id = NULL_OBJID;

  /*NOTE: The information about the node to be unevaluated will be retrieved
   *      in the EMdeactivateState (using EMgetInInfo). Note that the 
   *      known dependent flag indicates node in question.
   */

  if (nodes_owner_id == NULL_OBJID)
  {
    /*Get my owners id.*/
    OM_S_CHANSELECT   to_owners;

    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_owners,
                                    index = 0,
                                    objidaddr = &my_owner_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;                                  
  }
  else my_owner_id = nodes_owner_id;

  /*My owner (or me if IMMED_OP) is a known dependent.*/
  flags = EMdeact_st_KNOWN_DEPENDENT;

  /*Unevaluate me and all who depend on me.*/
  deact_options = (options & EMuneval_ADD_MANAGER ? EMdeact_st_ADD_MANAGER :
                                                    NULL); 
  deact_options |= (options & EMuneval_DELETE_SSI ? EMdeact_st_DELETE_SSI :
                                                    NULL); 
  deact_options |= (options & EMuneval_DO_DISPLAY ? EMdeact_st_DO_DISPLAY :
                                                    NULL);
  if(options & EMuneval_IMMEDIATE_OPER)
  {
    deact_options |= EMdeact_st_IMMEDIATE_OPER;
    OM_stat = om$send(msg = message EMSdpr.EMdeactivateState(EMmsg, 
                            &inlist, flags, deact_options, display_count,
                            display_ids, env),
                      targetid = my_id);
  }
  else
  {
    /*Since the entire limb is being uneval'd, I need to get all the geom and
     * topology.
     */
    IGRint         num_surfs=0, num_active=0;
    extern void    EFalloc_list();
    extern OMuword OPP_EMSdpr_class_id;

    OM_stat = om$send(msg = message EMSsurface.EMgetSurfsOfPrim(EMmsg,
                            my_id, &surf_list, &num_surfs, &num_active),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    EFalloc_list(EMmsg, &inlist.sflist.surf_ids, inlist.sflist.num_surfs,
                 &inlist.sflist.array_size, num_surfs, SF_INCR, NULL);
    if (!(1 & *EMmsg)) goto wrapup;                 

    for(ii=0; ii<num_surfs; ii++)
      inlist.sflist.surf_ids[ii] = surf_list[ii];
          
    inlist.sflist.num_surfs = num_surfs;

    EFgetLoopsEdges(EMmsg, 
                    inlist.sflist.num_surfs, 
                    inlist.sflist.surf_ids,
                    &inlist.lplist.array_size,
                    &inlist.lplist.num_loops,
                    &inlist.lplist.loop_ids,
                    &inlist.edlist.array_size,
                    &inlist.edlist.num_edges,
                    &inlist.edlist.edge_ids,
                    OM_Gw_current_OS);
    if (!(1 & *EMmsg)) goto wrapup;
                    
    OM_stat = om$send(msg = message EMSdpr.EMdeactivateState(EMmsg, 
                            &inlist, flags, deact_options, display_count,
                            display_ids, env),
                      targetid = my_owner_id);
  }
  if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
  else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (env->md_id.objid != NULL_OBJID)
  {
    /*
     * Input object has an entry in the R-tree. Update the R-tree range for 
     * each component of the composite surface as there is a change in the 
     * topology of the component surfaces. Fix for TR# 119528382.
     */

    UpdateSurfaceRtreeRange (my_id, OM_Gw_current_OS, &env->md_id); 
  }

  save_msg = *EMmsg;

  /*NOTE: If I have been removed from the model due to a disjoint case, I will
   *      now once again be back in the model.
   */

  /*NOTE: If in the middle of an update, the tree will be inactive. Therefore,
   *      the getactiveid send will return NULL_OBJID.
   */

  /*Determine the (possibly) new active state.*/
  OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                          &active_GRid, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  *active_id = active_GRid.objid;

  if (save_msg == EMS_I_CantRecompute)
  {
    *EMmsg = EMS_I_CantRecompute;
    goto wrapup;
  }

  if (options & EMuneval_REMOVE_UNEVAL_NODES) /*DOESNT SUPPORT IMMED_OPER!!!*/
  {
    GRobjid           new_active_id=NULL_OBJID;
    IGRboolean        action = TRUE;
    IGRushort mask = EMSIS_ACTIVE_STATE;
    
    OM_stat = om$send(msg = message EMSdpr.EMremoveOpnd(EMmsg, my_id, env, 
                            &new_active_id, &my_owner_id, NULL),
                      targetid = my_owner_id);
    if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    else if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*The removal may have caused the active id to change.*/
    if (new_active_id != NULL_OBJID)
    {
      *active_id = new_active_id;
    }
    else
    {
      /*The removal may have deleted the entire tree.*/
      OM_stat = om$is_objid_valid(objid = *active_id);
      if (OM_stat != OM_S_SUCCESS)
      {
        /*Yup, it sure did.*/
        *active_id = my_id;
      }                               
    }

    /*If I am a DPR, my active state bit should be turned on.*/
    OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg, &action, 
                            &mask),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg) && OM_stat != OM_W_UNKNOWN_MSG) goto wrapup;
    OM_stat = OM_S_SUCCESS;
  }
  else if (options & EMuneval_ADD_MANAGER)
  {
    /*Add a shell manager to me.*/
    OM_stat = om$send(msg = message EMSdpr.EMaddManager(EMmsg, my_id, TRUE,
                            NULL),
                      targetid = my_owner_id);
    if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    else if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

#if correctOrient_STUFF_REALLY_WAS_GOOD_AFTER_ALL
  /*Correct the orientation.*/
  if (my_owner_id != NULL_OBJID)
  {
    OM_stat = om$send(msg = message EMSdpr.EMcorrectOrient(EMmsg),
                      targetid = my_owner_id);
    if(OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
    else if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }
#endif

  if (batch_id) *batch_id = my_owner_id;

  if ((options & EMuneval_DO_DISPLAY) && !(options & EMuneval_DONT_REDRAW))
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

    for(ii=0; ii<*display_count; ii++)
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
    if (surf_list) om$dealloc(ptr = surf_list);
    if (inlist.sflist.surf_ids) om$dealloc(ptr = inlist.sflist.surf_ids);
    if (inlist.lplist.loop_ids) om$dealloc(ptr = inlist.lplist.loop_ids);
    if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);
    if ((options & EMuneval_DO_DISPLAY) && 
        !(options & EMuneval_DONT_REDRAW) && 
        *display_ids) 
    {
      om$dealloc(ptr = *display_ids);
      *display_ids = NULL;
      *display_count = 0;
    }

    EMWRAPUP(*EMmsg, OM_stat, "EMSsurface.EMunevaluate")
    return(OM_stat);
}

/*
  ABSTRACT

  Given a surface/composite surface object it updates the r-tree range of 
  the surface/component surfaces.

  HISTORY

  Sanjay  12/05/95  Creation
*/
 
static void UpdateSurfaceRtreeRange
(
  PWobjid sfobj,
  PWosnum os,
  struct GRid *md_grid
)
{
  int num_sfs=0, sf=0;
  PWobjid *p_sf=NULL;
  long sts=EMS_S_Success, msg=EMS_S_Success;

  /*
   * Get all the component surfaces of the composite surface.
   */
  num_sfs = pwNumSfsOfCompSf (sfobj, os);
  if (!num_sfs)
    return;

  p_sf = (PWobjid *) alloca (num_sfs * sizeof (PWobjid));
  if (!p_sf)
    return;

  num_sfs = pwGetSfsOfCompSf (sfobj, os, p_sf);

  /*
   * Update the R-tree range for each individual surface.
   */
  for (sf=0; sf<num_sfs; sf++)
  {
    sts = om$send (msg = message EMSsubbs.EMput_range_in_rtree (&msg, NULL, 
                                 NULL, NULL, TOPOLOGICAL, md_grid),
                   senderid = p_sf[sf], targetid = p_sf[sf], targetos = os); 
  }

  return;
}

end implementation EMSsurface;


#if TAKEN_OUT_BUT_LEFT_SO_ILL_REMEMBER_WHAT_I_DID
  /* I will have some surfaces/loops/edges only if I am a primitive solid
     or a leaf surface.
     SM     02-Aug-1990.

     Changed the code to get the surfaces/loops/edges if this node has any
     that are added.  The above statement is incorrect if a local mod exists.
     DLB 11/05/90
  */

  if (options & EMuneval_IMMEDIATE_OPER &&
      EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                        OPP_EMSdpr_class_id, FALSE))
  {
    /*Get my ininfo*/
    OM_stat = om$send(msg = EMSdpr$EMgetInInfo(EMmsg, &inlist, NULL_OBJID,
                            TRUE, EMget_in_inf_SHELL_ALL_DEP),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
  }
  else
  {
    if (!EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                           OPP_EMSsubbs_class_id, FALSE))   /* Is primitive */
    {                         
      EFgetcomponents(EMmsg, my_id, my_id, OM_Gw_current_OS,
                      &inlist.sflist.num_surfs, &surf_list);
      if (!(1 & *EMmsg)) goto wrapup;
  
      inlist.sflist.array_size = inlist.sflist.num_surfs + INITIAL;
      inlist.sflist.surf_ids = (GRobjid *) om$malloc
                          (size = inlist.sflist.array_size * sizeof(GRobjid));
      if (!inlist.sflist.surf_ids)
      {*EMmsg = EMSE_E_NoDynamicMemory; goto wrapup;}
  
      for (ii=0; ii<inlist.sflist.num_surfs; ii++) 
        inlist.sflist.surf_ids[ii] = surf_list[ii].objid;
    }
    else                                                  /* Is leaf surf */
    {
      inlist.sflist.surf_ids = (GRobjid *) om$malloc
                          (size = INITIAL * sizeof(GRobjid));
      if (!inlist.sflist.surf_ids)
      {*EMmsg = EMSE_E_NoDynamicMemory; goto wrapup;}
  
      inlist.sflist.array_size = INITIAL;
      inlist.sflist.surf_ids[0] = my_id;
      inlist.sflist.num_surfs = 1;
    }  
    EFgetLoopsEdges(EMmsg, 
                    inlist.sflist.num_surfs, 
                    inlist.sflist.surf_ids,
                    &inlist.lplist.array_size,
                    &inlist.lplist.num_loops,
                    &inlist.lplist.loop_ids,
                    &inlist.edlist.array_size,
                    &inlist.edlist.num_edges,
                    &inlist.edlist.edge_ids,
                    OM_Gw_current_OS);
    if (!(1 & *EMmsg)) goto wrapup;
  }

#endif
