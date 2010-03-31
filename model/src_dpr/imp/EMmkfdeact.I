/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmkface;

#include "EMS.h"
#include "emsdef.h" 
#include "emserr.h"
#include "emserr.h"
#include "EMSbnd.h"
#include "EMSrgmod.h"
#include "EMSbnddef.h"
#include "EMSopt.h"

from EMSloop            import  EMtreemod, EMgivenestinfo, EMnesting,
                                EMset_props;
from EMSboundary        import  EMget_objid, EMcheck_props, 
                                EMgetsurface_info;
from EMSsubbs           import  EMpartolbasis;
from EMSloopset         import  EMnesting, EMtreemod;
from EMSloop            import  EMactivate_loop;
from EMSedge            import  EMget_props, EMset_props;

method EMdeactivate(IGRlong *EMmsg; IGRshort *option;
                    struct GRmd_env *env;
                    GRobjid **display_ids;
                    IGRint *display_count)

/*
Notes
        This file contains the deactivate implementation
        for MAKE FACE operation.

History  RC     05/01/87        Creation date
         RC     11/02/87        Modified for version 1.1.0
         DLB    07/26/88        Added code to set surface to inactive.
         RC     11/21/88        Fixed a bug regarding edge_in/edge_out
                                logic.
         RC     08/17/89        Added the logic to set the seam bit 
                                correctly for ed_cp_eds. This will be
                                used incase of physically closed surfaces.
*/

{
  IGRlong               OM_stat, mthd_stat, rc;
  IGRint                i, num_sf_comp;

  IGRushort             ls_props, lp_props, ed_props;

  GRobjid               ls_id;

  struct  GRid          my_GRid, mod_sf_GRid,  *sf_comp_ids;

  IGRboolean            delete, world;

  OM_S_CHANSELECT       com_ed_chan, sf_ls_chan, sfcomp_chan;                      

  struct EMSnest_info   nesting;
  struct EMSpartolbasis partolbasis;

  union EMSssi_table    *ssi;
  struct EMSmfssi_table *my_info;
  void                  EFgetobjids();
  extern void           EFrpl_old_new_eds();
 
  /* **************************************************************** */

*EMmsg = EMS_S_Success;
OM_stat = OM_S_SUCCESS;

ssi = NULL;
sf_comp_ids = NULL;

delete = (*option & EMS_UNDO_SAVE) ? FALSE : TRUE;

sfcomp_chan.type = OM_e_addr;
sfcomp_chan.u_sel.addr = &ME.GRcmpowner->to_components;  

/*
 * get the save state information table.
 */

OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI ( &mthd_stat, 
                     &ssi), targetid = my_id);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
my_info = &ssi->mf_info;

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;
mod_sf_GRid.objid = my_info->surface_ids[0];
mod_sf_GRid.osnum = OM_Gw_current_OS;

EFgetobjids (&mthd_stat, &my_GRid, &sfcomp_chan, &sf_comp_ids,
             &num_sf_comp, OPP_EMSsubbs_class_id, &mod_sf_GRid, 1);
EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup); 

 if (*option & EMS_DO_DISPLAY)
 {
   IGRint      inx;          /*DECLARE*/
   enum GRdpmode display_mode = GRbehe;
   IGRboolean  got_it = FALSE;    


   /*Has the added surface already been erased?*/
   for (inx=0; inx<*display_count; inx++)
   {
     if ( (*display_ids)[inx] == my_info->surface_ids[0] )
     {
       got_it = TRUE;
       break;
     }
   }

   if (!got_it)
   {
     /**Erase the modified surface and store it**/

     OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat, 
                             &env->md_env.matrix_type, 
                             env->md_env.matrix, &display_mode,
                             &env->md_id),
                       targetid = my_info->surface_ids[0]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError,wrapup);

     /**Store modified id**/
     EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     if (!(1 & *EMmsg)) goto wrapup;

     (*display_ids)[*display_count] = my_info->surface_ids[0];
     (*display_count)++;
   }

   for ( i = 0; i < num_sf_comp; i++)
   {
     got_it = FALSE;

     /*Has the added surface already been erased?*/
     for (inx=0; inx<*display_count; inx++)
     {
       if ( (*display_ids)[inx] == sf_comp_ids[i].objid )
       {
         got_it = TRUE;
         break;
       }
     }

     if (!got_it)
     {
       /*Erase the added surface and store it.*/
       OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                               &env->md_env.matrix_type, 
                               env->md_env.matrix, &display_mode,
                               &env->md_id),
                         targetid = sf_comp_ids[i].objid);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
   
       /**Store modified id**/
       EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                           DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
       if (!(1 & *EMmsg)) goto wrapup;

       (*display_ids)[*display_count] = sf_comp_ids[i].objid;
       (*display_count)++;
     }
   }
 } 

/*
 *  The loops that were moved/(copied and moved) on the
 *  partial surface. Since the (u,v) space of the the
 *  partial surface is different from that of original
 *  surface (u,v) space, they have to be tranformed to 
 *  the new (u,v) space. If the edge had more than
 *  one owner, its copy was made. If the edge was
 *  connected to another edge across its common edge
 *  channel, it was discconectd and its copy was
 *  onnected to the common edge.
 *  
 * This information is also stored in ssi table. It is
 * stored in the following manner:
 *
 *  my_info->ed_cp_ed_ids[0] -- ed1
 *           ed_cp_ed_ids[1] -- ed1_cp
 *           ed_cp_ed_ids[2] -- ed2
 *           ed_cp_ed_ids[3] -- ed2_cp
 *           ed_cp_ed_ids[4] -- ed3 
 *           ed_cp_ed_ids[5] -- ed3_cp
 *                              .
 *                              .
 */

if (my_info->num_edges_copied)
{
   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   for (i = 0; i < my_info->num_edges_copied; i++)
   {
     OM_stat = om$send (msg = message Root.move_chan ( com_ed_chan, 
                         my_info->ed_cp_ed_ids[2*i+1], OM_Gw_current_OS,
                         com_ed_chan),
                        targetid = my_info->ed_cp_ed_ids[2*i]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_OMerror,wrapup);

     /*
      * It may be possible that the original ed is a seam edge but not
      * its copy. In such a case make common edge also a seam edge.
      */

     OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                         &ed_props),
                        targetid = my_info->ed_cp_ed_ids[2*i]);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     if (ed_props & EMED_SEAM)
     {
      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                          EMED_SEAM, EMS_O_ON),
                         senderid = my_info->ed_cp_ed_ids[2*i],
                         p_chanselect = &com_ed_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     } /* if (ed_props & EMED_SEAM) */
   } /* for (i = 0; i < my_info->num_edges_copied; i++) */

 } /* if (my_info->num_edges_copied) */

 /*
  * take out the loops_in and save them if the option is
  * EMS_UNDO_SAVE. Otherwise, delete them.
  */

 for (i = 0; i < my_info->num_regions_in[0]; i++)
 {
   OM_stat = om$send(msg = message EMSloop.EMtreemod( &mthd_stat, 
                      &nesting, (delete?DELETE:EXTRACT), NULL),
                     targetid = my_info->region_in_ids[i]);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

   if (!delete)
   {
     IGRshort option = EMS_O_OFF;
     IGRushort props = EMLP_ACTIVE;

     OM_stat = om$send (msg = message EMSloop.EMset_props( &mthd_stat, 
                         props, option),
                        targetid = my_info->region_in_ids[i]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

   } /* if (!delete) */

 } /* for (i = 0; i < my_info->num_regions_in[0]; i++) */

 /* 
  * put the out_loops back into the loopset
  */

 OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
 EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$send (msg = message EMSboundary.EMget_objid(
                     &mthd_stat, &ls_id),
                    senderid = my_info->surface_ids[0],
                    p_chanselect=&sf_ls_chan);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  if (my_info->num_regions_out[0])
  {
     world = TRUE;
     OM_stat = om$send(msg=message EMSsubbs.EMpartolbasis( &mthd_stat, 
                        &env->md_env.matrix_type, 
                         env->md_env.matrix, &world, FALSE, &partolbasis.tol),
                       targetid = my_info->surface_ids[0]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

     partolbasis.mattyp = &env->md_env.matrix_type;
     partolbasis.mat = env->md_env.matrix;
     partolbasis.in_world = TRUE;
     partolbasis.is_valid = TRUE;

     for(i=0; i< my_info->num_regions_out[0]; i++)
     {
       OM_stat = om$send (msg = message EMSloop.EMactivate_loop( 
                           &mthd_stat),
                          targetid = my_info->region_out_ids[i]);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

       OM_stat = om$send(msg = message EMSloop.EMgivenestinfo( &mthd_stat,
                          &nesting),
                         targetid= my_info->region_out_ids[i]);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

       OM_stat = om$send(msg = message EMSloopset.EMnesting(
                          &mthd_stat, &nesting, &partolbasis),
                         targetid=ls_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

       if(IF_EQ_OBJID(ls_id,nesting.parent))
           OM_stat = om$send(msg = message EMSloopset.EMtreemod(
                      &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
                     targetid = ls_id);
       else
           OM_stat = om$send(msg = message EMSloop.EMtreemod(
                &mthd_stat, &nesting, ADD_CHILD, &partolbasis),
                targetid = nesting.parent);

       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

     } /* for(i=0; i< my_info->num_regions_out[0]; i++) */

  } /* if (my_info->num_regions_out[0]) */

  /*
   * it may be possible that surfaces' loopset are natural after
   * this process. Make a check for this and set the EMLS_NATURAL
   * bit appropriately.
   */

  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
  lp_props = NULL;
  ed_props = NULL;
  OM_stat = om$send (msg = message EMSboundary.EMcheck_props (&mthd_stat,
                      &ls_props, &lp_props, &ed_props), 
                     targetid = ls_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  /*
   * take out the edges_in. delete edges_in if the 
   * option is  not EMS_UNDO_SAVE and put back edges_out
   */
 
  if (my_info->num_regions)
  {
    EFrpl_old_new_eds (&rc, my_info->cum_num_edges_out, 
                       my_info->edge_out_ids, my_info->num_edges_in, 
                       my_info->edge_in_ids, OM_Gw_current_OS, FALSE,
                       delete, TRUE);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  } /* if (my_info->num_regions) */


/*
 * if the option is EMS_UNDO_SAVE, make myself inactive and 
 * make the surface(made face) unlocatable and undisplayable.
 * Otherwise, delete myself and made face.
 */

if (delete)
{
  for (i = 0; i < num_sf_comp; i++)
  {
    OM_stat = om$send (msg = message GRgraphics.GRdelete( &mthd_stat, 
                        env), targetid = sf_comp_ids[i].objid);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  } /*  for (i = 0; i < num_sf_comp; i++) */

  /*
   * disconnect my components from me before deleting.
   * This is done to turn off the necessary property bits
   * of the components.
   */

  if (*option & EMS_DELETE_DPR)
  {
      OM_stat = om$send (msg = message GRconnector.GRdisconn (
                          &mthd_stat, &my_GRid),
                         p_chanselect = &sfcomp_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

      OM_stat = om$send (mode = OM_e_wrt_message,
                        msg = message Root.delete(1),
                        targetid = my_id);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_Fail,wrapup);
   }

} /* if (delete) */
else
{
  /*
   * set my properties ( GRIS_LOCATABLE and GRIS_DISPLAYABLE)
   * to false
   */

  ME.GRgraphics->properties &= ~GRIS_LOCATABLE;
  ME.GRgraphics->properties &= ~GRIS_DISPLAYABLE;

  /*
   * change the properties (GRIS_DISPLAYBLE and
   * GRIS_LOCATABLE) of 
   * surfaces across my lm_sfcomp_chan to
   * to FALSE
   */

  for ( i = 0; i < num_sf_comp; i++)
  {
     EFsetsfstate(&mthd_stat, sf_comp_ids[i].objid, sf_comp_ids[i].osnum,
                  EMS_O_OFF);
     EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  } /* for ( i = 0; i < num_sf_comp; i++) */

} /* else for if (delete) */

wrapup:
EMWRAPUP (*EMmsg, OM_stat, "In EMcsmkface.EMdeactivate");
if (ssi) om$dealloc(ptr = ssi);
if (sf_comp_ids) om$dealloc(ptr = sf_comp_ids);

return (OM_stat);

}

end implementation EMSsfmkface;
