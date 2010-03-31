/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "EMSprop.h"
#include "ndmacros.h"
#include "stdio.h"

extern OMuword OPP_EMSsfeditmgr_class_id;

from EMSdpr import EMevaluateOps, EMcleanupComputeInfo;

method EMevaluate(IGRlong *EMmsg; IGRushort options; 
                  IGRint num_to_eval; GRobjid *eval_ids;
                  struct GRmd_env *env; GRobjid **display_ids;
                  IGRint *display_count;
                  IGRint num_path_ids; GRobjid *path_ids)

/*
Description
    This message will evaluate unevaluate nodes in the DPR tree.  The result
    of this send is directly dependent on the options given.  When a
    node is evaluated all dependent (evalauated) nodes will be recomputed.
    
Return Values
    EMS_S_Success if all is well.

Notes
    About parameters:
      options:
        EMeval_EVAL_ALL_SHELLED - Evaluate all unevaluated nodes in the tree. 
          The manager objects will be deleted.
        EMeval_EVAL_GIVEN_SHELLED - Evaluate only those nodes given in the
          parameter list.  All other unevaluated nodes will remain as they
          are. 
        EMeval_EVAL_ALL_NONSHELLED - Evaluate all nodes in the tree that are
          unevaluated and dont have a manager attached.  This situation will
          occur when nodes are removed or are swapped.
        EMeval_DONT_CHECK_DEPENDENTS - Do not proceed up the tree checking for
          dependents.  This option should only be used when the sender is
          ABSOLUTELY sure that ALL dependents of this node will recompute
          due to already being unevaluated.  The initial reason for adding
          this option is for removing nodes from the tree.
        EMeval_DO_DISPLAY - Perform efficient internal display.
        EMeval_DONT_REDRAW - Don't redraw surfaces.  Instead, return then to
          the sender.
      num_to_eval - besides the target objid, the number of unevaluated
                    objids in the eval_ids array . 
      eval_ids - array of     "       "       "       "       "       ".
      env - current environment.
      display_ids - Contains the surfaces erased if options is
                    EMeval_DO_DISPLAY AND EMeval_DONT_REDRAW.  Sender should
                    set pointer to NULL. 
      display_count - Number of surfaces in above array.  Sender should set
                      parameter to 0.
      num_path_ids,  
      path_ids      - The array of ids to follow down the tree.  The code
                      assumes this is the path that contains nodes to         
                      evaluate and only this path will be checked.  If a  
                      general search is required then these 2 parameters
                      should be passes as NULL.  If passed, the array will
                      only be read and left to the sender to free.

                      Since the path will usually be gotten thru the 
                      EMgettreepath msg, the code assumes the ids are in a 
                      bottom to top order (that is, the top id will be 
                      path_ids[num_path_ids-1]).

History
    DLB 03/05/91 Mod to drive NDcompute_node - not finished...
    DLB 10/14/89 Added compute_info parms to EMevauateOps send.
    DLB 10/08/89 Added num_path_ids and path_ids parameters.
    DLB 12/22/88 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  GRobjid           target_id;
  IGRint            num_compute_info=0;
  struct EMScompute_info *compute_info=NULL;
  struct GRid       active_GRid;
  struct EMSinlist  inlist;
  struct EMSoutlist outlist;
  OM_S_CHANSELECT   to_owners;
  OMuword           dumosnum;
  IGRboolean        unused;
  IGRushort tmp_options;
  

  /*SHOULD!!!!-> Add the nodes list to the batch and then return*/

#if THIS_STUFF_GETS_FIXED_TO_WORK_IN_AN_ASSOCIATIVE_WORLD
  *EMmsg = EMS_S_Success;

  active_GRid.osnum = OM_Gw_current_OS;
  active_GRid.objid = my_id;
  target_id = my_id;

  if (ME.GRgraphics->properties & GR_RIGID_RELATIONSHIP)
  {
    EMmake_chanselect(GRconnector_to_owners, &to_owners);
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_owners,
                                    index = 0,
                                    objidaddr = &target_id,
                                    osnumaddr = &dumosnum);
    if (OM_stat == OM_W_INDEXEMPTY) OM_stat = OM_S_SUCCESS; /*No owner.*/
    else if (!(1 & OM_stat)) goto wrapup;
    else
    {
      /*I have a valid owner.  See if its a manager.*/    
      if (EFisAncestryValid(EMmsg, target_id, OM_Gw_current_OS,
                            OPP_EMSsfeditmgr_class_id, FALSE))
      {
        /*My owner is a manager object so his owner is part of the valid
         *  tree.
         */
        OM_stat = om$get_objid_at_index(objid = target_id,
                                        p_chanselect = &to_owners,
                                        index = 0,
                                        objidaddr = &target_id,
                                        osnumaddr = &dumosnum);
        if (!(1 & OM_stat)) goto wrapup;
      }
      OM_stat = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                              &active_GRid, NULL),
                        targetid = target_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }
  }

  inlist.sflist.array_size = 0;
  inlist.sflist.num_surfs = 0;
  inlist.sflist.surf_ids = NULL;
  inlist.lplist.array_size = 0;
  inlist.lplist.num_loops = 0;
  inlist.lplist.loop_ids = NULL;
  inlist.edlist.array_size = 0;
  inlist.edlist.num_edges = 0;
  inlist.edlist.edge_ids = NULL;
  inlist.modlist.mod_id = NULL_OBJID;

  outlist.sflist.array_size = 0;
  outlist.sflist.num_surfs = 0;
  outlist.sflist.surf_ids = NULL;
  outlist.sfmodlist.array_size = 0;
  outlist.sfmodlist.num_surfs = 0;
  outlist.sfmodlist.surf_ids = NULL;
  outlist.lplist.array_size = 0;
  outlist.lplist.num_loops = 0;
  outlist.lplist.loop_ids = NULL;
  outlist.edlist.array_size = 0;
  outlist.edlist.num_edges = 0;
  outlist.edlist.edge_ids = NULL;
  outlist.rnglist.replacing_id = NULL_OBJID;
  
  tmp_options = (options & EMeval_EVAL_ALL_SHELLED ?
                                                EMeval_op_EVAL_ALL_SHELLED : 
                                                NULL); 
  tmp_options |= (options & EMeval_EVAL_GIVEN_SHELLED ?
                                                EMeval_op_EVAL_GIVEN_SHELLED :
                                                NULL);   
  tmp_options |= (options & EMeval_DO_DISPLAY ? EMeval_op_DO_DISPLAY :
                                                    NULL);   
  tmp_options |= (options & EMeval_EVAL_ALL_NONSHELLED ?
                                              EMeval_op_EVAL_ALL_NONSHELLED : 
                                              NULL);  
  tmp_options |= (options & EMeval_DONT_CHECK_DEPENDENTS ?
                                            EMeval_op_DONT_CHECK_DEPENDENTS : 
                                            NULL);
/***************
  OM_stat = om$send(msg = message EMSdpr.EMevaluateOps(EMmsg,
                          tmp_options, num_to_eval, eval_ids,
                          env, &inlist, &outlist, &unused, display_ids,
                          display_count, 
                          num_path_ids, path_ids, num_path_ids-1,
                          &num_compute_info, &compute_info), 
                    targetid = active_GRid.objid);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
**************/

  /*Clean up the compute_info structure.  
   * If the evaluate was successful then delete the ssi, and ri info.  Also
   * free the ssi, ri and con_top arrays.
   * If unsuccessful then simply free the ssi, ri and con_top arrays.
   */
  if (*EMmsg != EMS_I_CantRecompute)
  {
    tmp_options = NULL;
    OM_stat = om$send(msg = message EMSdpr.EMcleanupComputeInfo(EMmsg, 
                            tmp_options, env, num_compute_info, compute_info),
                      targetid = active_GRid.objid);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if ((options & EMeval_DO_DISPLAY) && !(options & EMeval_DONT_REDRAW))
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
    IGRint i;
    
    for (i=0; i<*display_count; i++)
    {
      if (om$is_objid_valid(objid = (*display_ids)[i]) == OM_S_SUCCESS)
      {
        OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                                &env->md_env.matrix_type,
                                env->md_env.matrix, &display_mode,
                                &env->md_id),
                          targetid = (*display_ids)[i]);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
    }
  }

  wrapup:
    if (inlist.sflist.surf_ids) om$dealloc(ptr = inlist.sflist.surf_ids);
    if (inlist.lplist.loop_ids) om$dealloc(ptr = inlist.lplist.loop_ids);
    if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);
    if (outlist.sflist.surf_ids) om$dealloc(ptr = outlist.sflist.surf_ids);
    if (outlist.sfmodlist.surf_ids)
        om$dealloc(ptr = outlist.sfmodlist.surf_ids);
    if (outlist.lplist.loop_ids) om$dealloc(ptr = outlist.lplist.loop_ids);
    if (outlist.edlist.edge_ids) om$dealloc(ptr = outlist.edlist.edge_ids);

    if ((options & EMeval_DO_DISPLAY) && 
       !(options & EMeval_DONT_REDRAW) && 
       *display_ids) 
    {
      om$dealloc(ptr = *display_ids);
      *display_ids = NULL;
      *display_count = 0;
    }
    if (compute_info) om$dealloc(ptr = compute_info);
#else
fprintf(stderr,"EMsfeval.I needs fixing!!\n");
OM_stat = OM_E_ABORT;
*EMmsg = EMS_E_InvalidSend;    
#endif

    EMWRAPUP(*EMmsg, OM_stat, "EMSsurface.EMevaluate")
    return(OM_stat);
}
end implementation EMSsurface;
