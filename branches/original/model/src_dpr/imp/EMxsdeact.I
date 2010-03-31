/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsec_st;

%safe
#include <math.h>
%endsafe


#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSxsection.h"
#include "EMSobjmgrdef.h"
#include "EMSobjmgr.h"

from EMSsubbs    import EMpartolbasis;
from EMSboundary import EMget_objid, EMcheck_props;
from EMSloopset  import EMtreemod, EMnesting;
from EMSloop     import EMtreemod, EMset_props, EMactivate_loop,
                        EMgivenestinfo;

extern OMuword OPP_EMSloopset_class_id;

/*
    This file contains the deactivate implementation needed
    for cross_section state.


History
    RC    09/01/88        Creation Date

*/

method EMdeactivate(
  IGRlong         *EMmsg; 
  IGRshort        *option;
  struct GRmd_env *md_env;
  GRobjid         **display_ids;
  IGRint          *display_count)

{
  OM_S_CHANSELECT          sf_ls_chan, ls_sf_chan, to_cmpnt_chan;
  struct   EMSpartolbasis  partolbasis;
  struct   EMSnest_info    nesting;
  struct   GRid            owner_GRid, cmpnt_GRid, my_GRid;
  union    EMSssi_table    *ssi;
  struct   EMSxsssi_table  *my_info;
  
  enum     GRdpmode        display_mode = GRbe;

  IGRlong                  OM_stat, mthd_stat, rc, *owner_index;

  IGRint                   cur_sf, i, j, cur_lp_in, cur_lp_out,
                           cum_num_sf_out, 
                           blksize;

  OMuint                   num_cmpnts;

  IGRboolean               delete, world, sf_already_erased, action;

  IGRushort                lp_props, ls_props, ed_props, mask;

  GRobjid                  ls_id, *sf_out;
  
  extern void              EFrealloc_if_needed(), EFsetsfstate();
  
  /* ********************************************************** */

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  ssi = NULL;
  delete = (*option & EMS_UNDO_SAVE) ? FALSE : TRUE;

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  partolbasis.mattyp = &md_env->md_env.matrix_type;
  partolbasis.mat = md_env->md_env.matrix;
  partolbasis.in_world = TRUE;
  partolbasis.is_valid = TRUE;
  world = TRUE;

  /*
   * Get the save state information table
   */

  OM_stat = om$send (msg = message EMSdpr.EMgetSSI (&mthd_stat,
                      &ssi), targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg,EMS_E_Fail,wrapup);

  my_info = &ssi->xs_info;

 /*
  * If the option EMS_UNDO_DELETE, the loops added in constructing
  * this state will have some edges constructed at this state and
  * are associated with the model. Remove these edges.
  */

 if (delete)
 {
   struct EMSfnmgr_info    fnmgr_info;
   GRobjid                 *act_eds = NULL, *inact_eds = NULL;
   IGRint                  num_act_eds = 0, num_inact_eds = 0, 
                           act_eds_arrsz = 0, inact_eds_arrsz = 0;
   extern void             EFfnmgr_manipulation();

   OM_stat = om$send (msg = message EMSxsection.EMget_associated_edges (
                       &mthd_stat, &act_eds, &inact_eds, &num_act_eds,
                       &num_inact_eds, &act_eds_arrsz, &inact_eds_arrsz,
                       EMSXS_ACT_EDGES, 1),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

   fnmgr_info.tips = act_eds;
   fnmgr_info.num_tips = num_act_eds;

   EFfnmgr_manipulation (&rc, OM_Gw_current_OS, EMSlabel_xsection, 
                         EMSFM_MANIP_DEL, EMSFM_KEY_TIP, &fnmgr_info, 
                         NULL);
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

   if (act_eds) om$dealloc (ptr = act_eds);
   
 } /* if (delete) */

 /*
  * Put back the surfaces taken out.
  * since the surfaces out should be put back at the
  * indices at the time of their removal, it is necceassy
  * to put them back in an order reverse to the one in which
  * they were taken out.
  *
  * o Connect the surface out to its owner if the composite id is
  *   not NULL_OBJID. Composite id will be NULL_OBJID if the cross
  *   section had only one cross_section plane and it was
  *   taken out during update.
  * o Make it active.
  * o display the surface if the caller has requested.
  * o Add a loopset to the surface.
  */

 if (my_info->num_composites)
 {
  cum_num_sf_out = 0;
  for (i = 0; i < my_info->num_composites; i ++)
    cum_num_sf_out += my_info->num_surfaces_out[i];

  sf_out = &my_info->surface_out_ids[cum_num_sf_out-1];
  owner_index = (IGRlong *) &my_info->composite_indices[cum_num_sf_out-1];

  owner_GRid.osnum = OM_Gw_current_OS;

  for(i = my_info->num_composites-1; i >= 0; i--)
  {
    owner_GRid.objid = my_info->composite_ids[i];     

    for(j = my_info->num_surfaces_out[i]-1; j >= 0; j--)
    {
      if (owner_GRid.objid != NULL_OBJID)
      {
       OM_stat = om$send(msg = message GRconnector.GRrigidconn(&mthd_stat,
                       &owner_GRid, owner_index),
                      targetid = *sf_out);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
      } /* if (owner_GRid.objid != NULL_OBJID) */

      EFsetsfstate(&mthd_stat, *sf_out, OM_Gw_current_OS, EMS_O_ON);
      EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      OM_stat = om$construct (classid = OPP_EMSloopset_class_id,
                              osnum = OM_Gw_current_OS, p_objid = &ls_id);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      OM_stat = om$send (msg = message Root.connect (ls_sf_chan,
                          NULL, *sf_out, OM_Gw_current_OS, sf_ls_chan,
                          NULL),
                         targetid = ls_id);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      if (*option & EMS_DO_DISPLAY)
      {
        EFrealloc_if_needed(&rc, display_ids, *display_count, 
                        DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
        EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

        (*display_ids)[*display_count] = *sf_out;
        (*display_count)++;

      } /* if (*option & EMS_DO_DISPLAY) */

      owner_index--;
      sf_out--;

    } /* for(j = my_info->num_surfaces_out[i]-1; j >= 0; j--) */

  } /* for(i = my_info->num_composites-1; i >= 0; i--) */

 } /* if (my_info->num_compsites) */

 /*
  * For each surface from/to which lps were removed/added,
  * o Erase the surface if it has not already been erased.
  * o Take out the loops_in and save them if the option is
  *   EMS_UNDO_SAVE. Otherwise, delete them. 
  * o If the option is EMS_UNDO_SAVE, turn off EMLP_ACTIVE property
  *   of the taken out loop. 
  */

 cur_lp_in = cur_lp_out = 0;
 for (cur_sf = 0; cur_sf < my_info->num_surfaces; cur_sf++)
 {
  if (*option & EMS_DO_DISPLAY)
  {
   sf_already_erased = FALSE;
   i = 0; 
   while (i < *display_count && !sf_already_erased)
   {
     if (IF_EQ_OBJID( (*display_ids)[i], my_info->surface_ids[cur_sf]) )
       sf_already_erased = TRUE;
     else i++;
   } /* while (i < *display_count && !sf_already_erased) */
 
   if (!sf_already_erased)
   {
     OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                         &md_env->md_env.matrix_type, 
                         md_env->md_env.matrix, &display_mode,
                         &md_env->md_id),
                        targetid = my_info->surface_ids[cur_sf]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     EFrealloc_if_needed(&rc, display_ids, *display_count, 
                        DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

     (*display_ids)[*display_count] = my_info->surface_ids[cur_sf];
     (*display_count)++;

   } /* if (!sf_already_erased) */

  } /* if (*option & EMS_DO_DISPLAY) */

  lp_props = EMLP_ACTIVE;

  for (i = 0; i < my_info->num_regions_in[cur_sf]; i++, cur_lp_in++)
  {
     OM_stat = om$send(msg = message EMSloop.EMtreemod( &mthd_stat, 
                        &nesting, (delete?DELETE:EXTRACT), NULL),
                       targetid = my_info->region_in_ids[cur_lp_in]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

     if (!delete)
     {
       OM_stat = om$send (msg = message EMSloop.EMset_props( &mthd_stat, 
                           lp_props, EMS_O_OFF),
                          targetid = my_info->region_in_ids[cur_lp_in]);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      } /* if (!delete) */

  } /* for (i = 0; i < my_info->num_regions_in[cur_sf]; 
            i++, cur_lp_in++) */

  OM_stat = om$send (msg = message EMSboundary.EMget_objid(
                      &mthd_stat, &ls_id),
                     senderid = my_info->surface_ids[cur_sf],
                     p_chanselect=&sf_ls_chan);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

 /* 
  * o put the out_loops back into the loopset
  */

  if (my_info->num_regions_out[cur_sf])
  {
   OM_stat = om$send(msg=message EMSsubbs.EMpartolbasis( &mthd_stat, 
                      &md_env->md_env.matrix_type, 
                      md_env->md_env.matrix, &world, FALSE, &partolbasis.tol),
                     targetid = my_info->surface_ids[cur_sf]);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

   for(i = 0; i < my_info->num_regions_out[cur_sf]; i++, cur_lp_out++)
   {
    OM_stat = om$send (msg = message EMSloop.EMactivate_loop( 
                        &mthd_stat),
                       targetid = my_info->region_out_ids[cur_lp_out]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

    OM_stat = om$send(msg = message EMSloop.EMgivenestinfo( &mthd_stat,
                       &nesting),
                      targetid= my_info->region_out_ids[cur_lp_out]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

    OM_stat = om$send(msg = message EMSloopset.EMnesting(
                       &mthd_stat, &nesting, &partolbasis),
                      targetid = ls_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

    if( IF_EQ_OBJID(ls_id, nesting.parent) )

      OM_stat = om$send(msg = message EMSloopset.EMtreemod(
                         &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
                        targetid = ls_id);
    else

      OM_stat = om$send(msg = message EMSloop.EMtreemod(
                         &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
                        targetid = nesting.parent);

    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

    } /* for (i = 0; i < my_info->num_regions_out[cur_sf]; 
            i++, cur_lp_out++) */
 
  } /* if (my_info->num_regions_out[cur_sf]) */

   /*
    * it may be possible that surfaces' loopset are natural after
    * this process. Make a check for this and set the EMLS_NATURAL
    * bit appropriately.
    */

   ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
   lp_props = ed_props = NULL;

   OM_stat = om$send (msg = message EMSboundary.EMcheck_props (&mthd_stat,
                       &ls_props, &lp_props, &ed_props), 
                      targetid = ls_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  } /* for (cur_sf = 0; cur_sf < my_info->num_sf_affected; cur_sf++) */

  /*
   * For each of the surfaces made active  during this operation:
   * o Erase the surface if it is not already been erased.
   * o Delete its loopset.
   * o If it is in the display_list, take it out.
   * o Make it inactive.
   */

  OM_stat = om$get_channel_count (object = me, 
               p_chanselect = &to_cmpnt_chan, count = &num_cmpnts);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  for (i = 1; i < num_cmpnts; i++)
  {
    OM_stat = om$get_objid_at_index ( object = me,
                 p_chanselect = &to_cmpnt_chan, index = i, 
                 objidaddr = &cmpnt_GRid.objid, 
                 osnumaddr = &cmpnt_GRid.osnum);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    if (*option & EMS_DO_DISPLAY)
    {
      sf_already_erased = FALSE;

      for (j = 0; j < *display_count; j++)
      {
        if ((*display_ids)[j] == cmpnt_GRid.objid)
        {
          sf_already_erased = TRUE;  
          blksize = *display_count - 1 - j;
          if (blksize)
          {
            OM_BLOCK_MOVE (&(*display_ids)[j+1], &(*display_ids)[j],
                           blksize * sizeof(GRobjid));

          }
          (*display_count)--;
          break;

        } /* if ((*display_ids[j] == cmpnt_GRid.objid) */

      } /* for (j = 0; j < *display_count; j++) */
 
      if (!sf_already_erased)
      {
        OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                           &md_env->md_env.matrix_type, 
                           md_env->md_env.matrix, &display_mode,
                           &md_env->md_id),
                          targetid = cmpnt_GRid.objid);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      } /* if (!sf_already_erased) */

    } /* if (*option & EMS_DO_DISPLAY) */

    EFsetsfstate(&mthd_stat, cmpnt_GRid.objid, cmpnt_GRid.osnum, 
                 EMS_O_OFF);
    EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    OM_stat = om$send (msg = message Root.delete (1),
                       senderid = cmpnt_GRid.objid,
                       p_chanselect = &sf_ls_chan);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  } /* for (i = 1; i < num_cmpnts; i++) */

  /*
   * Update common edge connections.
   */

  OM_stat = om$send (msg = message EMSxsection.EMconnect_edges (
                      &mthd_stat, md_env),
                     p_chanselect = &to_cmpnt_chan);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  /*
   * Make my last state as active state.
   */

  action = TRUE;
  mask = EMSIS_ACTIVE_STATE;

 /*  NOTE- My last state may be of class other than dpr in which case 
  *        it won't understand this message.  So I just check the return 
  *        om message and ignore an unknown msg warning.
  */

 OM_stat = om$send(msg = message EMSdpr.EMsetprops(&mthd_stat, &action, 
                    &mask),
                   p_chanselect = &to_cmpnt_chan);
 if (OM_stat == OM_W_UNKNOWN_MSG) OM_stat = OM_S_SUCCESS;
 EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  /*
   *   IF option is EMS_UNDO_DELETE or EMS_DELETE_DPR, delete 
   *    my self. Otherwise collapse ids[] vla. It is done 
   *   because, undo is trying to send a delete message to all 
   *   of associated surfaces, loops and edges saved in ids[] vla.
   *   In such a case the associated objects will have to decide 
   *   whether they should be deleted or not. This process is 
   *   expensive and can be avoided by collapsing EMSdpr.ids[] vla
   *   right now.
   */

  if (delete)
  {
   /*
    * disconnect my components from me before deleting.
    * This is done to turn off the necessary property bits
    * of the components.
    */

   if (*option & EMS_DELETE_DPR || *option & EMS_UNDO_DELETE)
   {
    OM_stat = om$send (msg = message GRconnector.GRdisconn (
                        &mthd_stat, &my_GRid),
                       p_chanselect = &to_cmpnt_chan);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    OM_stat = om$send (mode = OM_e_wrt_message, 
                        msg = message Root.delete(1),
                       targetid = my_id);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

   } /* if (*option & EMS_DELETE_DPR || *option & EMS_UNDO_DELETE) */
   else
   {
     OM_stat = om$vla_set_dimension (varray = me->ids, size = 0);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   } /* else for if (*option & EMS_DELETE_DPR || 
                     *option & EMS_UNDO_DELETE) */

  } /* if (delete) */
  else
  {
   ME.GRgraphics->properties &= ~GRIS_LOCATABLE;
   ME.GRgraphics->properties &= ~GRIS_DISPLAYABLE;

  } /* else for if (delete) */

 wrapup:
  
  if (ssi) om$dealloc (ptr = ssi);
  EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMdeactivate");
  
  return (OM_stat);
}

end implementation EMSxsec_st;
