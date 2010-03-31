/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

/*
History
    DLB 02/13/92    Handle cleanup better.
    DLB 04/25/91    If UNEVAL_STATE then don't del me.
    SM  03/31/92    skip invalid surf_GRid, partolbasis was incorrectly being
		    passed as '&partolbasis' to EMnesting, etc. etc.
*/


#include "EMS.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "emsdattyp.h"
#include "EMSbnddef.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "OMmacros.h"

from EMSloopset import  EMget_loops,
                        EMnesting,
                        EMtreemod;
from EMSloop    import  EMtreemod,
                        EMactivate_loop,
                        EMgivenestinfo,
                        EMtree_traverse,
                        EMget_loops;
from EMSgradata import  EMchangeSurface;
from EMSboundary import EMcheck_props,
                        EMget_objid;
 
extern OMuword  OPP_EMSgradata_class_id;
extern OMuword OPP_EMSsubbs_class_id;

method  EMround_graceful_exit(IGRlong                   *EMmsg;
                              struct GRmd_env           *my_env;
                              struct GRid               surf_GRid;
                              struct EMSpartolbasis     *partolbasis;
                              IGRint                    num_orgnl_loops;
                              GRobjid                   *orgnl_loops;
                              struct EMround_save_state *svst_info)
{
 
 IGRlong                      stat_OM, msg;
 IGRint                       i, j, k;
 IGRint                       buf_size, depth, num_current_loops;
 IGRint                       num_surf_ids;
 IGRint                       display_count = 0;
 IGRboolean                   is_loop_original;
 IGRushort            ls_props, lp_props, ed_props;
 IGRshort                     deactivate_option;
 enum GRdpmode                display_mode;
 GRobjid                      *display_ids = NULL;
 GRobjid                      *current_loops;
 GRobjid                      surf_loopset;
 struct GRid                  temp_id, *surf_ids;
 struct EMSnest_info          nesting;
 OM_S_CHANSELECT              to_comps, to_inner,
                              to_loops, to_loopset;

/*-------------------------------------------------------------------*/

stat_OM = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

UI_status("Operation failed.......Recovering Model");

surf_ids = NULL;
current_loops = NULL;

stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
if (! (1 & stat_OM)) goto wrapup;

if (svst_info)
 {
   IGRushort dpr_props=0;

  stat_OM = om$send(msg = message EMSsfround.EMprepare_rnd_ssi(&msg,
                          svst_info),
                    targetid = my_id);
  EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

  deactivate_option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

  dpr_props = ME.EMSdpr->dpr_props;

  if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
    deactivate_option |= EMS_DELETE_DPR;
  else 
    ME.EMSdpr->dpr_props &= ~EMS_NULL_STATE;

  stat_OM = om$send(msg = message EMSdpr.EMdeactivate(&msg,
                          &deactivate_option, my_env, &display_ids,
                          &display_count),
                          targetid = my_id);

  ME.EMSdpr->dpr_props = dpr_props;

  EMerr_hndlr (!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

  display_mode = GRbd;

  for(i=0; i<display_count; i++)
   {
    if (om$is_objid_valid(objid = display_ids[i], 
                          osnum = OM_Gw_current_OS) == OM_S_SUCCESS)
     {
      stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                              &my_env->md_env.matrix_type, 
                              my_env->md_env.matrix, &display_mode,
                              &my_env->md_id),
                        targetid = display_ids[i]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, msg, wrapup);
     }
   }      
  
  if (display_ids) om$dealloc(ptr = display_ids);
 }
else
 {
  temp_id.objid = my_id;
  temp_id.osnum = OM_Gw_current_OS;

  EFgetobjids (&msg, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
               OPP_EMSsubbs_class_id, NULL, 0);
  EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);

  display_mode = GRbe;

  for (i=0; i<num_surf_ids; i++)
   {
    stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                            &my_env->md_env.matrix_type, 
                            my_env->md_env.matrix, &display_mode,
                            &my_env->md_id),
                      targetid = surf_ids[i].objid);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
   
    stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg, my_env),
                      targetid = surf_ids[i].objid);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
   }

  if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
  {
    stat_OM = om$send(mode = OM_e_wrt_message,
                      msg = message Root.delete(1),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM), *EMmsg, msg, wrapup);
  }
 }

if (num_orgnl_loops)
 {
  if (om$is_objid_valid(objid = surf_GRid.objid, 
                          osnum = surf_GRid.osnum) != OM_S_SUCCESS)
   goto wrapup;

  stat_OM = EMmake_chanselect (EMSloop_to_inner, &to_inner);
  stat_OM = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  if (! (1 & stat_OM)) goto wrapup;

  display_mode = GRbe;
  stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &my_env->md_env.matrix_type, 
                          my_env->md_env.matrix, &display_mode,
                          &my_env->md_id),
                    targetid = surf_GRid.objid,
                    targetos = surf_GRid.osnum);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);

  stat_OM = om$send (msg = message EMSboundary.EMget_objid(&msg,
                           &surf_loopset),
                     senderid = surf_GRid.objid,
                     p_chanselect = &to_loopset);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

  depth = MAXINT; 
  buf_size = NULL;
  stat_OM = om$send (msg = message EMSloopset.EMget_loops (&msg,
                           EMS_OPT_ALL, &depth, &current_loops,
                           NULL, &buf_size, &num_current_loops), 
                     targetid = surf_loopset);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError, wrapup);

  buf_size += num_current_loops;

  for (i=0; i<num_current_loops; i++)
   {
    is_loop_original = FALSE;
    j = 0;

    while (! is_loop_original && j<num_orgnl_loops)
     {
      if (current_loops[i] == orgnl_loops[j]) 
          is_loop_original = TRUE;
      else
          j++;
     }

    if (is_loop_original)
     {
      for (k=j; k<(num_orgnl_loops - 1); k++)
           orgnl_loops[k] = orgnl_loops[k+1];
      num_orgnl_loops--;
     }
    else
     {
      stat_OM = om$send(msg = message EMSloop.EMtreemod(&msg, &nesting,
                              DELETE, partolbasis),
                         targetid = current_loops[i]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
     } 
   } /* for (i=0; i<num_current_loops; i++) */

  for (i=0; i<num_orgnl_loops; i++)
   {
    /*
     * some of the orgnl_loops may have non_original loops as
     * their childern. It is therefore needed to extract and delete
     * them.
     */
     
    depth = MAXINT;
    num_current_loops = NULL;
    stat_OM = om$send(msg = message EMSloop.EMget_loops (&msg,
                             EMS_OPT_ALL, &depth, &current_loops,
                             NULL, &buf_size, &num_current_loops), 
                      senderid = orgnl_loops[i],
                      p_chanselect = &to_inner);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopsetError,wrapup);
  
    buf_size += num_current_loops;

    for (k=0; k<num_current_loops; k++)
     {
      is_loop_original = FALSE;
      j = 0;

      while (! is_loop_original && j<num_orgnl_loops)
       {
        if (current_loops[k] == orgnl_loops[j]) 
            is_loop_original = TRUE;
        else
            j++;
       }
 
      if (! is_loop_original)
       {
        stat_OM = om$send (msg = message EMSloop.EMtreemod (&msg,
                                 &nesting, DELETE, partolbasis),
                           targetid = current_loops[k]);
        EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_LoopError,wrapup);
       } 
     } /* for (k=0; k<num_current_loops; k++) */

    stat_OM = om$send (msg = message EMSloop.EMactivate_loop (&msg),
                       targetid = orgnl_loops[i]);
    EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

    nesting.parent = NULL_OBJID;
    stat_OM = om$send(msg = message EMSloop.EMgivenestinfo(&msg, 
                            &nesting),
                      targetid = orgnl_loops[i]);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_NestError, wrapup);

    if (! IF_NULL_OBJID(nesting.parent))
     {
      stat_OM = om$send (msg = message EMSloop.EMtreemod (&msg, &nesting,
                               EXTRACT, partolbasis),
                         targetid = orgnl_loops[i]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
     }
       
    nesting.parent = NULL_OBJID;
    stat_OM = om$send(msg = message EMSloopset.EMnesting(&msg, &nesting,
                            partolbasis),
                      targetid = surf_loopset);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_NestError, wrapup);

    if (IF_EQ_OBJID(surf_loopset, nesting.parent))
     {
      stat_OM = om$send(msg = message EMSloopset.EMtreemod(&msg, &nesting,
                              ADD_CHILD, partolbasis),
                        targetid = surf_loopset);
     }
    else
     {
      stat_OM = om$send(msg = message EMSloop.EMtreemod(&msg, &nesting,
                              ADD_CHILD, partolbasis),
                        targetid = nesting.parent);
     }
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_NestError, wrapup);
   } /* for (i=0; i<num_orgnl_loops; i++) */

  stat_OM = om$send(msg = message EMSloop.EMtree_traverse (&msg,
                          message EMSgradata.EMchangeSurface (&msg,
                                  surf_GRid.objid),
                          MAXINT, 1, &OPP_EMSgradata_class_id, TRUE,
                          EMLP_PLOOP, NULL, NULL),
                    senderid = surf_loopset,
                    p_chanselect = &to_loops);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
  lp_props = NULL;
  ed_props = NULL;
	
  stat_OM = om$send (msg = message EMSboundary.EMcheck_props(&msg,
                           &ls_props, &lp_props, &ed_props),
                     targetid = surf_loopset);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);

  display_mode = GRbd;
  stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                          &my_env->md_env.matrix_type, 
                          my_env->md_env.matrix, &display_mode,
                          &my_env->md_id),
                    targetid = surf_GRid.objid,
                    targetos = surf_GRid.osnum);
  EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);
 }

wrapup:
  /* DLB 2/13/92 - reset ids vla just in case this is a recompute case.*/
  om$vla_set_dimension(varray = ME.EMSdpr->ids,
                       size = 0);

  EMWRAPUP (*EMmsg, stat_OM, "EMSsfrnd.EMrd_grexit")
  if (surf_ids) om$dealloc (ptr = surf_ids);
  if (current_loops) om$dealloc (ptr = current_loops);
  return (stat_OM);
}

end implementation  EMSsfround;
                                  
