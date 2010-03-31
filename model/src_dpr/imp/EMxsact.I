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

from EMSsubbs    import  EMpartolbasis;
from EMSboundary import EMget_objid;
from EMSloopset  import EMtreemod, EMnesting, EMset_props;
from EMSloop     import EMtreemod, EMset_props, EMactivate_loop,
                        EMgivenestinfo;

extern OMuword   OPP_EMSloopset_classid;

/*
    This file contains the activate implementation needed
    for cross section operation. 


History
  RC    09/01/88        Creation Date

*/


method EMactivate (
IGRlong             *EMmsg;
IGRshort            *option;
struct GRmd_env     *md_env;
GRobjid             **display_ids;
IGRint              *display_count)

{
  OM_S_CHANSELECT            sf_ls_chan, ls_sf_chan, to_cmpnt_chan;
  struct   GRid              cmpnt_GRid, owner_GRid;
  struct   EMSpartolbasis    partolbasis;
  struct   EMSnest_info      nesting;
  struct   EMSxsssi_table    *my_info;
  union    EMSssi_table      *ssi;

  enum     GRdpmode          display_mode = GRbe;
  
  IGRlong                    OM_stat, mthd_stat, rc;

  IGRint                     cur_sf, i, cur_lp_out, cur_lp_in, j, k,
                             blksize;

  OMuint                     num_cmpnts;

  IGRboolean                 sf_already_erased, world;

  GRobjid                    ls_id, *sf_out;

  extern void                EFrealloc_if_needed(), EFsetsfstate();

  /* ************************************************************ */

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  ssi = NULL;
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
   * Mark myself displayable and locatable.
   */

  ME.GRgraphics->properties |= (GRIS_LOCATABLE | GRIS_DISPLAYABLE);

  /*
   * get the save state information table
   */

  OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI (&mthd_stat,
                      &ssi), targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail,wrapup);

  my_info = &ssi->xs_info;

  /*
   * Make all of cross section planes active added at this state.
   * Also,put them in erased surfaces list if the option is 
   * EMS_DO_DISPLAY. Add a loopset to each of surfaces made active.
   */

  OM_stat = om$get_channel_count (object = me, 
               p_chanselect = &to_cmpnt_chan, count = &num_cmpnts);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  for (i = 1; i < num_cmpnts; i++)
  {
   OM_stat = om$get_objid_at_index (object = me, 
                p_chanselect = &to_cmpnt_chan, index = i, 
                objidaddr = &cmpnt_GRid.objid, 
                osnumaddr = &cmpnt_GRid.osnum);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   EFsetsfstate(&mthd_stat, cmpnt_GRid.objid, cmpnt_GRid.osnum,
                EMS_O_ON);
   EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
    
   OM_stat = om$construct (classid = OPP_EMSloopset_class_id, 
                           osnum = OM_Gw_current_OS, p_objid = &ls_id); 
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   OM_stat = om$send (msg = message Root.connect (ls_sf_chan, NULL,
                       *sf_out, OM_Gw_current_OS, sf_ls_chan, NULL), 
                      targetid = ls_id);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   if (*option & EMS_DO_DISPLAY)
   {
     EFrealloc_if_needed(&rc, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
 
     (*display_ids)[*display_count] = cmpnt_GRid.objid;
     (*display_count)++;

   } /* if (*option & EMS_DO_DISPLAY) */

  } /* for (i = 1; i < num_cmpnts; i++) */

  /*
   * If there are any surfaces from/to which lps are 
   * removed/added,
   *  o Erase the surface if it has not already been erased.
   *  o Take out the loops taken out.
   *  o Add the loops added.
   */

  cur_lp_in = cur_lp_out = 0;
  for (cur_sf = 0; cur_sf < my_info->num_surfaces; cur_sf++)
  {
    if (*option & EMS_DO_DISPLAY)
    {
      sf_already_erased = FALSE;
      i = 0;
      for (i = 0; i < *display_count; i++)
      {
        if (IF_EQ_OBJID((*display_ids)[i], my_info->surface_ids[cur_sf]))
        {
          sf_already_erased = TRUE;
          break;
        }

      } /* for (i = 0; i < *display_count; i++) */

      if (!sf_already_erased)
      {
        OM_stat = om$send (msg = message GRgraphics.GRdisplay (&mthd_stat,
                            &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &display_mode,
                            &md_env->md_id),
                           targetid = my_info->surface_ids[cur_sf]);
        EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

        EFrealloc_if_needed(&rc, display_ids, *display_count,
                            DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
                
      } /* if (!sf_already_erased) */

    } /* if (*option & EMS_DO_DISPLAY) */

    for(i = 0; i < my_info->num_regions_out[cur_sf]; i++, cur_lp_out++)
    {
      OM_stat = om$send(msg = message EMSloop.EMtreemod( &mthd_stat,
                         &nesting, EXTRACT, NULL),
                       targetid = my_info->region_out_ids[cur_lp_out]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
       
      OM_stat = om$send (msg = message EMSloop.EMset_props ( &mthd_stat, 
                          EMLP_ACTIVE, EMS_O_OFF), 
                         targetid = my_info->region_out_ids[cur_lp_out]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

    } /* for(i = 0;i< my_info->num_regions_out[cur_sf];i++,cur_lp_out++)*/

    /* 
     * put the in_loops back into the loopset. Also, turn off
     * EMLS_NATURAL bit.
     */

    OM_stat = om$send (msg = message EMSboundary.EMget_objid( &mthd_stat,
                        &ls_id),
                     senderid = my_info->surface_ids[cur_sf],
                     p_chanselect=&sf_ls_chan);
    EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

    OM_stat = om$send (msg = message EMSloopset.EMset_props (&mthd_stat,
                       EMLS_NATURAL, EMS_O_OFF), targetid = ls_id);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

    OM_stat = om$send(msg=message EMSsubbs.EMpartolbasis( &mthd_stat,
                       &md_env->md_env.matrix_type, md_env->md_env.matrix,
                       &world, FALSE, &partolbasis.tol),
                      targetid = my_info->surface_ids[cur_sf]);
    EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

    for(i=0; i< my_info->num_regions_in[cur_sf]; i++, cur_lp_in++)
    {
      OM_stat = om$send(msg = message EMSloop.EMactivate_loop( 
                         &mthd_stat),
                       targetid = my_info->region_in_ids[cur_lp_in]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      OM_stat = om$send(msg = message EMSloop.EMgivenestinfo( &mthd_stat,
                         &nesting), 
                        targetid= my_info->region_in_ids[cur_lp_in]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

      OM_stat = om$send(msg = message EMSloopset.EMnesting( &mthd_stat,
                         &nesting, &partolbasis), targetid=ls_id);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

      if(IF_EQ_OBJID(ls_id, nesting.parent))

        OM_stat = om$send(msg = message EMSloopset.EMtreemod( &mthd_stat,
                           &nesting, ADD_CHILD, &partolbasis),
                          targetid = ls_id);
      else
        OM_stat = om$send(msg = message EMSloop.EMtreemod( &mthd_stat,
                           &nesting, ADD_CHILD, &partolbasis),
                          targetid = nesting.parent);
        EMerr_hndlr(!(1&OM_stat&OM_stat),*EMmsg,EMS_E_NestError,wrapup);

    } /* for(i=0; i< my_info->num_regions_in[cur_sf]; i++, cur_lp_in++) */

  } /* for (cur_sf = 0; cur_sf < my_info->num_surfaces; cur_sf++) */

  /*
   * Some of the surfaces need to be taken out for the lift
   * operation. For each of these surfaces:
   *
   * o Erase the surface if it has not already been erased.
   * o Disconnect the surface from its owner if the owner is not 
   *   NULL_OBJID. Owner may be NULL_OBJID in case of single_sf
   *   cross section.
   * o Make it inactive.
   * o Delete its loopset.
   */

  if (my_info->num_composites)
  {
    sf_out = my_info->surface_out_ids;

    for ( i = 0; i < my_info->num_composites; i++)
    {
      owner_GRid.objid = my_info->composite_ids[i];
      owner_GRid.osnum = OM_Gw_current_OS;

      for (j = 0; j < my_info->num_surfaces_out[i]; j++, sf_out++)
      {
        if (*option & EMS_DO_DISPLAY)
        {
          sf_already_erased = FALSE;
          for (k = 0; k < *display_count; k++)
          {
           if ((*display_ids)[k] == *sf_out)
           {
            sf_already_erased = TRUE;
            blksize = *display_count - 1 - k;
            if (blksize)
              OM_BLOCK_MOVE (&(*display_ids)[k+1], &(*display_ids)[k],
                 blksize * sizeof(GRobjid));
            (*display_count)--;

           } /* if ((*display_ids)[k] == *sf_out) */

          } /* for (k = 0; k < *display_count; k++) */

          if (!sf_already_erased)
          {
            OM_stat = om$send(msg = message GRgraphics.GRdisplay(
                               &mthd_stat, &md_env->md_env.matrix_type, 
                               md_env->md_env.matrix, &display_mode,
                               &md_env->md_id),
                              targetid = *sf_out);
            EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

          } /* if (!sf_already_erased) */

        } /* if (*option & EMS_DO_DISPLAY) */

        if (owner_GRid.objid != NULL_OBJID)
        {
          OM_stat = om$send (msg = message GRconnector.GRdisconn (
                              &mthd_stat, &owner_GRid),
                             targetid = *sf_out);
          EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

        } /* if (owner_GRid.objid != NULL_OBJID) */

        EFsetsfstate(&mthd_stat, *sf_out, OM_Gw_current_OS, EMS_O_OFF);
        EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

        OM_stat = om$send (msg = message Root.delete (1),
                           senderid = *sf_out,
                           p_chanselect = &sf_ls_chan);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      } /* for (j = 0; j < my_info->num_surfaces_out[i]; j++, sf_out++) */

    } /* for ( i = 0; i < my_info->num_composites; i++) */

  } /* if (my_info->num_composites) */

  
  wrapup:
   if (ssi) om$dealloc (ptr = ssi);
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsec_st.EMactivate");
   return (OM_stat);
}

end implementation EMSxsec_st;
