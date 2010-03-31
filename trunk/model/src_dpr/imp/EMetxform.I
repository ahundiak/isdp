/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedittree;

#include "msdef.h" /* MS message codes */
#include "emsdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "EMSdpr.h"
#include "nddef.h"
#include "ndmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

#if DEBUG
#include "stdio.h"
#endif

#include "matypemx.h"
#include "mainvmx.h"

from EMSsurface  import EMunevaluate;
from EMSdprparam import EMget_display_ids, EMput_display_ids,
                        EMputGetChangedId;

extern OMuword OPP_EMScompsurf_class_id;

method GRxform(IGRlong         *EMmsg; 
               struct GRmd_env *env; 
               IGRshort        *matrix_type; 
               IGRmatrix       matrix; 
               GRobjid         *newobjid)
/*
Description

Notes

History
   WBC 12/17/93     Update the display_ids in the EMSdprparam object at the end
                    of the method if necessary.  Currently, if an error is
                    returned by certain method/function calls, the display_ids
                    may not be posted.
    Sudha   06/23/93     Modified for BSprototype ansification

    DLB 01/24/91    Added support for EMSdprparam object.
    DLB 11/20/90    Added support for localized recompute and kicking off the
                    NDupdate via the batch.
    DLB 11/07/89    Added parameter to EMunevaluate pass to handle possible
                    case of the node being removed due to disjoint case.
    DLB 10/15/89    Handle failures.
    DLB 10/07/89    Creation. 
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            display_count=0, ii;
  GRobjid           active_id, *display_ids=NULL, param_id;
  IGRint            num_sf_GRids=0; 
  struct GRid       *sf_GRids=NULL;
  IGRboolean        can_eval=TRUE, MAinvmx(), MAtypemx(),
                    EFisAncestryValid(), node_is_composite=FALSE,
                    update_display_ids = FALSE;
  IGRushort options;



# if DEBUG
  fprintf(stderr,"EMetxform - xforming node %d\n", ME.EMSedittree->node_id);
# endif

  *EMmsg = MSSUCC;

  ex$message(msgnumb = EMS_P_ClearPromptField)
  ex$message(msgnumb = EMS_I_UnevalAffecNodes)

  OM_stat = EFsend_to_param(EMmsg, message EMSdprparam.EMget_display_ids(EMmsg,
                                   &display_count, &display_ids, NULL),
                            ME.EMSedittree->node_id, ME.EMSedittree->node_os,
                            &param_id, NULL); 
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                            

  update_display_ids = TRUE;

  /*EMuneval_DELETE_SSI |*/
  options = EMuneval_DO_DISPLAY | EMuneval_DONT_REDRAW;
  OM_stat = om$send(msg = message EMSsurface.EMunevaluate(EMmsg, options,
                          env, &display_ids, &display_count, &active_id,
                          ME.EMSedittree->nodes_owner_id, NULL),
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  if (*EMmsg == EMS_I_CantRecompute)
  {
    can_eval = FALSE;
    goto wrapup;
  }

  if (display_count)
  {
    OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                            display_count, display_ids, NULL),
                      targetid = param_id,
                      targetos = ME.EMSedittree->node_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                         
    display_count = 0;
    display_ids = NULL;
    update_display_ids = FALSE;
  }

  /*NOTE: Once the node has been unevaluated there is no need to worry about
   *      the possiblilty of the node having been removed due to a disjoint
   *      situation.
   */

  /*Before xforming get the surfs of the node_id if it is a composite.  If
   * a failure occurs then the recovery will return the model to active 
   * before the surfs are xformed back.  By getting the surf ids directly,
   * they can be xformed back even if a recovery has occured.
   */
  if (EFisAncestryValid(EMmsg, 
                        ME.EMSedittree->node_id,
                        ME.EMSedittree->node_os,
                        OPP_EMScompsurf_class_id, FALSE))
  {
    EFgetcomponents(EMmsg, 
                    ME.EMSedittree->node_id, ME.EMSedittree->node_id,
                    ME.EMSedittree->node_os,
                    &num_sf_GRids, &sf_GRids);
    if (!(1 & *EMmsg)) goto wrapup;
    node_is_composite = TRUE;
  }                        
  else num_sf_GRids = 1;

  OM_stat = om$send(msg = message GRgraphics.GRxform(EMmsg, env, 
                          matrix_type, matrix, newobjid), 
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  {
    GRobjid *tmp_ptr;
    ii = 1;
    tmp_ptr=&ME.EMSedittree->node_id;
    OM_stat = om$send(msg = message EMSdprparam.EMputGetChangedId(EMmsg, 
                            &ii, &tmp_ptr, 
                            EMputGetChangedId_PUT),
                      targetid = param_id,
                      targetos = ME.EMSedittree->node_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
  }

  /*Cut out eval ops stuff from here*/

  /*Add the xform'd node to the batch*/
  {
    struct GRid node_GRid;

    node_GRid.objid = ME.EMSedittree->node_id;
    node_GRid.osnum = ME.EMSedittree->node_os;

    nd$wait_batch(type = GR_GEOM_POSTED,
                  nb_obj = 1,
                  l_object = &node_GRid);

    /*JUST DO IT!*/
    nd$exec_batch();
  }

  if (*EMmsg == EMS_I_CantRecompute) 
  {
    IGRmatrix new_matrix; 
    IGRshort  n=4, new_matrix_type;

    can_eval = FALSE;

    /*Move the node back.*/
    if(!MAinvmx(EMmsg, &n, matrix, new_matrix))
    {
      *EMmsg = EMS_E_BSerror;
      goto wrapup;
    }
    else 
      MAtypemx(EMmsg, new_matrix, &new_matrix_type);

    for(ii=0; ii<num_sf_GRids; ii++)
    {
      OM_stat = om$send(msg = message GRgraphics.GRxform(EMmsg, env, 
                              &new_matrix_type, new_matrix, newobjid), 
                        targetid = node_is_composite ? sf_GRids[ii].objid :
                                                       ME.EMSedittree->node_id,
                        targetos = ME.EMSedittree->node_os);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    
    }
  }

  wrapup:

    if (update_display_ids && display_count)
    {
      OM_stat = om$send(msg = message EMSdprparam.EMput_display_ids(EMmsg,
                                          display_count, display_ids, NULL),
                        targetid = param_id,
                        targetos = ME.EMSedittree->node_os);
    }

    if (sf_GRids) om$dealloc(ptr = sf_GRids);

    EMWRAPUP (*EMmsg, OM_stat, "EMSedittree.NDxform");
    return(OM_stat);
}
end implementation EMSedittree;

#if THIS_IS_THE_OLD_WAY_OF_ISSUING_THE_EVALUATE_THE_NEW_WAY_IS_VIA_NDUPDATE
  /*Init the in and out list structures.*/
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
  outlist.rnglist.num_repl_info = 1;
  outlist.rnglist.replace_info = &tmp_repl_info;
  outlist.rnglist.replace_info->replacing_id = ME.EMSedittree->node_id;


  /*Next get the range of the replacing node.*/
  world = TRUE;
  OM_stat = om$send(msg = GRgraphics$GRgetrang(EMmsg,
                          &env->md_env.matrix_type,
                          env->md_env.matrix,
                          &world, 
                          outlist.rnglist.replace_info->range),
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  ex$message(msgnumb = EMS_I_ReEvalAffecNodes)

  /*Get the path for a more efficient EMevaluateOps pass.*/
  OM_stat = om$send(msg = EMSsurface$EMgettreepath(EMmsg, &path_ids,
                          &num_path_ids, NULL),
                    targetid = ME.EMSedittree->node_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  options = EMeval_op_DO_DISPLAY | EMeval_op_EVAL_ALL_NONSHELLED;
  can_eval = TRUE;
  OM_stat = om$send(msg = EMSdpr$EMevaluateOps(EMmsg, options,
                          0, NULL, env, 
                          &inlist, &outlist,
                          &can_eval,
                          &display_ids, &display_count,
                          num_path_ids, path_ids, num_path_ids-1,
                          &num_compute_info, &compute_info), 
                    targetid = active_id,
                    targetos = ME.EMSedittree->node_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

#endif
