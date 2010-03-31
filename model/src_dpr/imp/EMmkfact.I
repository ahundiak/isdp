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

from EMSsubbs		import	EMpartolbasis;
from EMSboundary	import	EMget_objid;
from EMSloopset		import	EMnesting, EMtreemod, EMset_props;
from EMSloop		import	EMgivenestinfo, EMnesting, EMtreemod,
                            EMset_props, EMactivate_loop;
from EMSedge        import  EMget_props, EMset_props;

extern OMuword OPP_EMSsubbs_class_id;

method EMactivate(IGRlong *EMmsg; IGRshort *option;
                  struct GRmd_env *env;
                  GRobjid **display_ids;
                  IGRint *display_count)

/*
Notes
	The method contains the activate implemntation needed for
	MAKE FACE operation.

History   RC    05/01/87        Creation Date
          RC    11/02/87        Modified for version 1.1.0
          DLB   07/26/88        Added code to set surface to active.
          RC    08/17/89        Added the logic to set the seam bit 
                                correctly for ed_cp_eds. This will be
                                used incase of physically closed surfaces.
*/


{

  IGRlong               OM_stat, rc, mthd_stat;
  IGRint                i, num_sf_comp;

  IGRushort             props;

  GRobjid               ls_id;
  
  struct GRid           my_GRid, sf_mod_GRid,  *sf_comp_ids;
  IGRboolean            world;

  OM_S_CHANSELECT       com_ed_chan, sf_ls_chan, sfcomp_chan;

  struct EMSnest_info   nesting;

  struct EMSpartolbasis partolbasis;

  union EMSssi_table    *ssi;
  struct EMSmfssi_table *my_info;
  extern void                  EFgetobjids(), EFrpl_old_new_eds();

  
  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  sf_comp_ids = NULL;
  ssi = NULL;

/*
 * set my properties to GRIS_LOCATABLE and GRIS_DISPLAYABLE
 */

ME.GRgraphics->properties |= (GRIS_LOCATABLE | GRIS_DISPLAYABLE);

/*
 * get the save state information table.
 */

OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI( &mthd_stat, &ssi),
			targetid = my_id);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
my_info = &ssi->mf_info;

if (*option & EMS_DO_DISPLAY)
{
  IGRint      inx;          /*DECLARE*/
  enum GRdpmode display_mode = GRbehe;
  IGRboolean  got_it = FALSE;    


  /*Has this surface already been erased?*/
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
    /**Erase this surface and store it**/

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
}


/*
 * take out the loops_out
 */

if (my_info->num_regions_out[0])
{

 for (i = 0; i < my_info->num_regions_out[0]; i++)
 {
   OM_stat = om$send(msg = message EMSloop.EMtreemod( &mthd_stat,
                      &nesting, EXTRACT, NULL),
                     targetid = my_info->region_out_ids[i]);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
       
   {
      IGRshort option = EMS_O_OFF;
      IGRushort props = EMLP_ACTIVE;
	
      OM_stat = om$send (msg = message EMSloop.EMset_props ( &mthd_stat, 
                         props, option), 
                        targetid = my_info->region_out_ids[i]);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
   }

 } /* for (i = 0; i < my_info->num_regions_out[0]; i++) */

} /* if (my_info->num_regions_out[0]) */

/* 
 * put the in_loops back into the loopset. Also, turn off
 * EMLS_NATURAL bit.
 */

OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = om$send (msg = message EMSboundary.EMget_objid( &mthd_stat,
                    &ls_id),
                   senderid = my_info->surface_ids[0],
                   p_chanselect=&sf_ls_chan);
EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

props = EMLS_NATURAL;
OM_stat = om$send (msg = message EMSloopset.EMset_props (&mthd_stat,
                    props, EMS_O_OFF), targetid = ls_id);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

world = TRUE;
OM_stat = om$send(msg=message EMSsubbs.EMpartolbasis( &mthd_stat,
                   &env->md_env.matrix_type, env->md_env.matrix,
                   &world, FALSE, &partolbasis.tol),
                  targetid = my_info->surface_ids[0]);
EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

partolbasis.mattyp = &env->md_env.matrix_type;
partolbasis.mat = env->md_env.matrix;
partolbasis.in_world = TRUE;
partolbasis.is_valid = TRUE;

for(i=0; i< my_info->num_regions_in[0]; i++)
{
  OM_stat = om$send(msg = message EMSloop.EMactivate_loop( &mthd_stat),
                    targetid = my_info->region_in_ids[i]);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

  OM_stat = om$send(msg = message EMSloop.EMgivenestinfo( &mthd_stat,
                     &nesting), targetid= my_info->region_in_ids[i]);
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

} /* for(i=0; i< my_info->num_regions_in[0]; i++) */

/*
 * take out the edges_out  and put back edges_in. Also, turn off
 * EMLP_NATURAL and EMLS_NATURAL bit of the loops and their
 * respective loopsets, these aedges are part of.
 * It may be possible that the edge is replaced by itself (was a 
 * bug which might corrput the old design files), in such a case
 * do not do any thing.
 */
 
  if (my_info->num_regions)
  {
    EFrpl_old_new_eds (&rc, my_info->cum_num_edges_out, 
                       my_info->edge_out_ids, my_info->num_edges_in, 
                       my_info->edge_in_ids, OM_Gw_current_OS, TRUE,
                       FALSE, TRUE);
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

  } /* if (my_info->num_regions) */

/*
 * see if any of the common edge connections have to be restablished.
 * The loops that were moved/(copied and moved) on the
 * partial surface. Since the (u,v) space of the the
 * partial surface is different from that of original
 * surface (u,v) space, they have to be tranformed to 
 * the new (u,v) space. If the edge had more than
 * one owner, its copy was made. If the edge was
 * connected to another edge across its common edge
 * channel, it was discconectd and its copy was
 * connected to the common edge.
 *
 * This information is stored ssi table in the 
 * following manner:
 *
 *  my_info->ed_cp_ed_ids[0]  --  ed1,
 *           ed_cp_ed_ids[1]  --  ed1_cp
 *           ed_cp_ed_ids[2]  --  ed2
 *           ed_cp_ed_ids[3]  --  ed2_cp
 *           ed_cp_ed_ids[4]  --  ed3
 *           ed_cp_ed_ids[5]  --  ed3_cp
 *                                .
 *                                .
 */

if (my_info->num_edges_copied)
{
   OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &com_ed_chan);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   for (i = 0; i < my_info->num_edges_copied; i++)
   {
     OM_stat = om$send (msg = message Root.move_chan (com_ed_chan, 
                         my_info->ed_cp_ed_ids[2*i], OM_Gw_current_OS,
                         com_ed_chan),
                        targetid = my_info->ed_cp_ed_ids[2*i+1]);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     /*
      * In case the original edge is a seam edge and not its
      * copy, common edge will be a seam edge. In such cases,
      * turn off the common edge's seam bit off.
      */

     OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                         &props),
                        targetid = my_info->ed_cp_ed_ids[2*i+1]);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     if (!(props & EMED_SEAM))
     {
      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                          EMED_SEAM, EMS_O_OFF),
                         senderid = my_info->ed_cp_ed_ids[2*i+1],
                         p_chanselect = &com_ed_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     } /* if (!(props & EMED_SEAM)) */

   } /* for (i = 0; i < my_info->num_edges_copied; i++) */

} /* if (my_info->num_edges_copied) */

/*
 * Turn on DISPLAYABLE and LOCATABLE properties of new constructed
 * surface.
 */

sfcomp_chan.type = OM_e_addr;
sfcomp_chan.u_sel.addr = &ME.GRcmpowner->to_components;

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;
sf_mod_GRid.objid = my_info->surface_ids[0];
sf_mod_GRid.osnum = OM_Gw_current_OS;

EFgetobjids (&mthd_stat, &my_GRid, &sfcomp_chan, &sf_comp_ids, 
             &num_sf_comp, OPP_EMSsubbs_class_id, &sf_mod_GRid, 1);
EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup); 

for (i = 0; i < num_sf_comp; i++)
{
   if (*option & EMS_DO_DISPLAY)
   {
     /**Store added surface**/
     EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     if (!(1 & *EMmsg)) goto wrapup;

     (*display_ids)[*display_count] = sf_comp_ids[i].objid;
     (*display_count)++;
   }

   EFsetsfstate(&mthd_stat, sf_comp_ids[i].objid, sf_comp_ids[i].osnum,
                EMS_O_ON);
   EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
} /* for (i = 0; i < num_sf_comp; i++) */

wrapup:
if (sf_comp_ids) om$dealloc(ptr = sf_comp_ids);
if (ssi) om$dealloc(ptr = ssi);
EMWRAPUP (*EMmsg, OM_stat, "In EMsfmkface.EMactivate");

return (OM_stat);

}

/*

 The following code is replaced by function call EFrpl_old_new_eds().

    edge_in = my_info->edge_in_ids;
    edge_out = my_info->edge_out_ids;

    ll = 0;
    for (i = 0; i < my_info->num_regions; i++)
    {
     if ( my_info->num_edges_in[i] > 1)
     {

      loop_id = my_info->region_ids[i];
      props = EMLP_NATURAL;

      OM_stat = om$send (msg = message EMSloop.EMset_props ( &mthd_stat, 
                          props, EMS_O_OFF), targetid = loop_id);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

      props = EMLS_NATURAL;
      OM_stat = om$send (msg = message EMSloopset.EMset_props( &mthd_stat,
                         props, EMS_O_OFF), 
                        senderid = loop_id, p_chanselect = &lp_ls_chan);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

      for (j = 0; j < my_info->num_edges_out[i]; j++, ll++)
      {
        OM_stat = om$get_index ( osnum_c = OM_Gw_current_OS,
                                 objid_c = loop_id,
                                 p_chanselect = &lp_ed_chan,
                                 objid = *edge_out,
                                 indexaddr = &edge_out_index);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
				 
        for (k = 0; k < my_info->num_edges_in[i]; k++)
	{
	  OM_stat = om$send (msg = message Root.connect( lp_ed_chan,
                              OM_K_MAXINT, *edge_in, OM_Gw_current_OS,
                              ed_lp_chan, edge_out_index+k),
                             targetid = loop_id);
          EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
          edge_in++;
        }

        OM_stat = om$send (msg = message Root.disconnect( lp_ed_chan,
                            *edge_out, OM_Gw_current_OS, ed_lp_chan),
                           targetid = loop_id);
        EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
        edge_out++;

      }

     }
     else
     {
       edge_in++;
       edge_out++;
     }

    }

*/

end implementation EMSsfmkface;
