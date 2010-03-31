/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
#include <stdio.h>
#include "emserr.h"
#include "OMmacros.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsdef.h"

from EMSsubbs    import EMexeinst, EMpartolbasis;
from EMSboundary import EMget_objid, EMgetsurface_info, EMcheck_props,
                        EMtree_traverse;
from EMSloopset  import EMtreemod, EMnesting;
from EMSloop     import EMtreemod, EMset_props, EMactivate_loop,
                        EMgivenestinfo;
from EMSedge     import EMget_props, EMconnect_edges, EMset_props;

extern OMuword OPP_EMSsubbs_class_id;

method EMlift_int_deactivate (
IGRlong	                           *EMmsg;
IGRshort                           *option;
struct GRmd_env                    *md_env;
GRobjid                            **display_ids;
IGRint                             *display_count;
IGRdouble                          *lift_vec;
IGRint                             *num_instructions;
struct EMinstruction_table_info    *move_info)

/*
    This file contains the deactivate implementation needed
    for all  LIFT operations. This is to be used internally only.


History
    03/12/93    AMD Maintain the dominant properites of the edges
                    being connected which might get reversed at the
                    time of connection

    03/03/92    DLB Added EFfix_parent_child_relationship call to fix up
                    assoc graph when an associative surface is removed.
    RC    03/29/89        Disconnect the ed3 and ed4 if they 
                          not NULL_OBJID before deleting the newly
                          created surface. This is done because the
                          deletion of new surfaces will delete their
                          edges (ed3 and ed4). When ed3 and ed4 are
                          deleted, their common edges' (ed1 and ed2) 
                          EMED_REVERSE_CONNECT and EMED_SUBORDINATE
                          properties are turned off.
    RC    11/15/88        Modified the logic in replacing the
                          new edges by their respective old edges.     
    DLB   07/26/88        Added code to (re)set surface inactive bit.
    RC    03/26/88        Creation Date

*/

{

struct EMSpartolbasis              partolbasis;
struct EMSlftssi_table          *my_info;
struct EMSnest_info                nesting;
struct GRid                        *cmpnt_sf_ids, my_GRid, reject_GRid,
                                   owner_GRid;
union EMSssi_table                 *ssi;
OM_S_CHANSELECT                    lm_sfcmpnt_chan, cm_ed_chan, 
                                   sf_ls_chan;
IGRvector                          lift_vector;

enum GRdpmode                      display_mode = GRbe;

IGRlong	                           OM_stat;
IGRlong   mthd_stat;
IGRlong   rc;

IGRlong                            *owner_index;
IGRint                             num_cmpnt_sf, cur_sf, i, j, 
                                   cur_ed,  
                                   cum_num_sf_out, cur_lp_out, cur_lp_in,
                                   EMsend_loops();

GRobjid                            *sf_out;

IGRboolean                         delete, world, put_ssi = FALSE,
                                   sf_already_erased,
                                   replace_one_by_many = FALSE;

IGRushort                  cn_ed_props, ed_props, lp_props, 
                                   ls_props;

GRobjid                            mod_sf_id, ls_id, ed1, 
                                   ed2, ed3, ed4, cm_node_ed;

void                               EFgetobjids(), EFrealloc_if_needed();
extern void                        EFrpl_old_new_eds();

/* ************************************************************** */


OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

ssi = NULL;
cmpnt_sf_ids = NULL;
delete = (*option & EMS_UNDO_SAVE) ? FALSE : TRUE;

lm_sfcmpnt_chan.type = OM_e_addr;
lm_sfcmpnt_chan.u_sel.addr = &ME.GRcmpowner->to_components;

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;

OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

partolbasis.mattyp = &md_env->md_env.matrix_type;
partolbasis.mat = md_env->md_env.matrix;
partolbasis.in_world = TRUE;
partolbasis.is_valid = TRUE;
world = TRUE;

/*
 * get the save state information table.
 */

OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI ( &mthd_stat, 
                    &ssi), targetid = my_id);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

my_info = &ssi->lft_info;

/*
 * get objids of new surafces, if any, constructed 
 * during the lift operation
 */

if (my_info->num_sf_lifted)
{
  reject_GRid.objid = my_info->sf_lifted_ids[0];
  reject_GRid.osnum = OM_Gw_current_OS;
  
} /* if (my_info->num_sf_lifted) */


EFgetobjids (&mthd_stat, &my_GRid, &lm_sfcmpnt_chan, &cmpnt_sf_ids,
             &num_cmpnt_sf, OPP_EMSsubbs_class_id, &reject_GRid, 
              my_info->num_sf_lifted);
EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup); 

/*
 * If there are any surfaces lifted,
 *   o Erase the surface.
 *   o Transform the surface back to original form
 *     by the lift_vector using the instruction table.
 *     It may be possible that the lift_vec is NULL. In such a
 *     case, the surface is not lifted and thus do not attempt
 *     to transform it. This will be the case in single surface
 *     lift process.
 */

if (my_info->num_sf_lifted)
{
 if (lift_vec)
 {
  for (i = 0; i < 3; i++)
    lift_vector[i] = -lift_vec[i];

 } /* if (lift_vec) */
  
  for (cur_sf = 0; cur_sf < my_info->num_sf_lifted; cur_sf++)
  {
   if (*option & EMS_DO_DISPLAY)
   {
    sf_already_erased = FALSE;
    i = 0; 
    while (i < *display_count && !sf_already_erased)
    {
     if (IF_EQ_OBJID( (*display_ids)[i], my_info->sf_lifted_ids[cur_sf]) )
       sf_already_erased = TRUE;
      else i++;
    } /* while (i < *display_count && !sf_already_erased) */
 
    if (!sf_already_erased)
    {
     OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                         &md_env->md_env.matrix_type, 
                         md_env->md_env.matrix, &display_mode,
                         &md_env->md_id),
                        targetid = my_info->sf_lifted_ids[cur_sf]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     EFrealloc_if_needed(&rc, display_ids, *display_count, 
                        DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

     (*display_ids)[*display_count] = my_info->sf_lifted_ids[cur_sf];
     (*display_count)++;

    } /* if (!sf_already_erased) */
   } /* if (*option & EMS_DO_DISPLAY) */

   /*
    * If the lift vector's length, there is no need to
    * transform the surafce. The lift vector length will be
    * 0 in case of single surface lift
    */

   if (lift_vec)
   {   
    OM_stat = om$send (msg = message EMSsubbs.EMexeinst ( &mthd_stat,
                    lift_vector, md_env, *num_instructions,
                    &mod_sf_id, move_info),
                   targetid = my_info->sf_lifted_ids[cur_sf]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError, wrapup);

    if (!IF_EQ_OBJID (mod_sf_id, my_info->sf_lifted_ids[cur_sf]))
    {
      put_ssi = TRUE;
      my_info->sf_lifted_ids[cur_sf] = mod_sf_id;
      (*display_ids)[i] = mod_sf_id;
    }

   } /* if (lift_vec) */

  } /* for (cur_sf = 0; cur_sf < my_info->num_sf_lifted; cur_sf++) */

} /* if (my_info->num_sf_lifted) */

/*
 * Common edges of some of the edges were moved.
 * The information available in the save state is
 * 1. The edge (edge1) from which the common edge was moved to 
 *    another edge (edge2).
 * 2. The edge (edge2) to which the the common edge was moved from 
 *    another edge (edge1).
 *
 * o For each pair, get the common edge of edge2. Disconnect
 *   edge2 from its common edge. Get the properties of edge1.
 *   Connect edge1 and its original common edge with the
 *   reverse_connect property of edge1.
 */

for (i = 0; i < my_info->num_ed_wmv_cm; i++)
{
  if(IF_NULL_OBJID(my_info->ed_ced_ids[2*i+1]))
   continue;

  OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                      &cm_node_ed),
                     senderid = my_info->ed_ced_ids[2*i+1],
                     p_chanselect = &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  OM_stat = om$send (msg = message Root.wild_disconnect( 
                      cm_ed_chan),
                     targetid = my_info->ed_ced_ids[2*i+1]);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                      &ed_props),
                     targetid = my_info->ed_ced_ids[2*i]);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  OM_stat = om$send (msg = message EMSedge.EMconnect_edges( 
                      &mthd_stat, (ed_props & EMED_REVERSE_CONNECT ?
                       EMED_REVERSE_CONNECT : NULL), FALSE, 
                       cm_node_ed, NULL_OBJID, NULL_OBJID, NULL),
                     targetid = my_info->ed_ced_ids[2*i]);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

} /* for (i = 0; i < my_info->num_ed_wmv_cm; i++) */

/*
 * For each surface from/to which lps were removed/added,
 * o Erase the surface if it has not already been erased.
 * o Take out the loops_in and save them if the option is
 *   EMS_UNDO_SAVE. Otherwise, delete them. 
 * o If the option is EMS_UNDO_SAVE, turn off EMLP_ACTIVE property
 *   of the taken out loop. 
 */

cur_lp_in = cur_lp_out = 0;
for (cur_sf = 0; cur_sf < my_info->num_sf_affected; cur_sf++)
{
 if (*option & EMS_DO_DISPLAY)
 {
  sf_already_erased = FALSE;
  i = 0; 
  while (i < *display_count && !sf_already_erased)
  {
     if (IF_EQ_OBJID( (*display_ids)[i], my_info->sf_affctd_ids[cur_sf]) )
       sf_already_erased = TRUE;
      else i++;
  } /* while (i < *display_count && !sf_already_erased) */
 
  if (!sf_already_erased)
  {
     OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                         &md_env->md_env.matrix_type, 
                         md_env->md_env.matrix, &display_mode,
                         &md_env->md_id),
                        targetid = my_info->sf_affctd_ids[cur_sf]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     EFrealloc_if_needed(&rc, display_ids, *display_count, 
                        DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

     (*display_ids)[*display_count] = my_info->sf_affctd_ids[cur_sf];
     (*display_count)++;

  } /* if (!sf_already_erased) */

 } /* if (*option & EMS_DO_DISPLAY) */

  lp_props = EMLP_ACTIVE;

  for (i = 0; i < my_info->num_regions_in[cur_sf]; i++, cur_lp_in++)
  {
     if(IF_NULL_OBJID(my_info->region_in_ids[cur_lp_in]))
      continue;

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

  /* 
   * o put the out_loops back into the loopset
   */

  OM_stat = om$send (msg = message EMSboundary.EMget_objid(
                      &mthd_stat, &ls_id),
                     senderid = my_info->sf_affctd_ids[cur_sf],
                     p_chanselect=&sf_ls_chan);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  OM_stat = om$send(msg=message EMSsubbs.EMpartolbasis( &mthd_stat, 
                     &md_env->md_env.matrix_type, 
                      md_env->md_env.matrix, &world, FALSE, &partolbasis.tol),
                    targetid = my_info->sf_affctd_ids[cur_sf]);
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
 * Some of the edges were replaced by a set of edges.
 * Perform an inverse process i.e., replaced new edges
 * with their original edges.
 */

EFrpl_old_new_eds (&rc, my_info->num_eds_rplcd, my_info->ed_rplcd_ids,
                   my_info->num_eds_in, my_info->ed_in_ids,
                   OM_Gw_current_OS, replace_one_by_many, delete, TRUE);
EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

/*
 *   IF option is EMS_UNDO_DELETE and EMS_DELETE_DPR, delete 
 *   my self. Otherwise collapse ids[] vla. It is done 
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

  if (*option & EMS_DELETE_DPR)
  {
   OM_stat = om$send (msg = message GRconnector.GRdisconn (
                       &mthd_stat, &my_GRid),
                      p_chanselect = &lm_sfcmpnt_chan);
   EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

   OM_stat = om$send (mode = OM_e_wrt_message, 
                      msg = message Root.delete(1),
                      targetid = my_id);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

  } /* if (*option & EMS_DELETE_DPR) */
  else
  {
    OM_stat = om$vla_set_dimension (varray = me->ids, size = 0);
    EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  } /* else for if (*option & EMS_DELETE_DPR) */

} /* if (delete) */
else
{
  ME.GRgraphics->properties &= ~GRIS_LOCATABLE;
  ME.GRgraphics->properties &= ~GRIS_DISPLAYABLE;

} /* else for if (delete) */


/*
 * The edges of the surface being lifted had their
 * common edge connections changed in some cases.
 * Reesatblish the old edge connections.
 *
 * There are four edge ids stored for edge of the surface 
 * lifted and had a common edge. These ids are stored in
 * in following manner:
 *
 * 1) Edge id                       -- ed1
 * 2) Edge's old cm_ed              -- ed2
 * 3) Edge's new cm_ed              -- ed3
 * 4) Edge's old cm_ed's_new_cm_ed  -- ed4
 *
 * There may be situations in_which ed3 and/or ed4 were not created
 * In these situations NULL_OBJID will be stored for ed3/ed4. Also
 * if ed3 is NULL_OBJID, ed1 is just disconnected and its 
 * EMED_REVERSE_CONNECT is still valid w.r.t to ed2. Similar
 * is the case if ed4 is NULL_OBJID.
 *
 * The following logic is used to re-establish the topology:
 *
 * o If ed3 == NULL_OBJID && ed4 == NULL_OBJID
 *   {
 *      ed1 and ed2 were not disconnected. Thus nothing needs to
 *      be done.
 *   }
 *   else If (ed3 == NULL_OBJID && ed4 != NULL_OBJID )
 *   {
 *     If (ed1 is reverse_connect)
 *        ed1 and ed2 are reverse connect.
 *     else
 *        ed1 and ed2 are not reverse connect.
 *
 *   }
 *   else If (ed3 != NULL_OBJID && ed4 == NULL_OBJID)
 *   {
 *      If (ed2 is reverse connect)
 *         ed1 and ed2 are reverse connect.
 *      else
 *        ed1 and ed2 are reverse connect.
 *   }
 *   else ( ed3 != NULL_OBJID && ed4 != NULL_OBJID )
 *   {
 *     if (ed2 and ed4 are reverse connect)
 *       ed1 and ed2 are not reverse connect.
 *     else
 *       ed1 and ed2 reverse connect.
 *   }
 */

 for (cur_ed = 0; cur_ed < my_info->num_eds_wcm_md; cur_ed++)
 {
   ed1 = my_info->ed_mcm_ed_ids[4*cur_ed];
   ed2 = my_info->ed_mcm_ed_ids[4*cur_ed+1];
   ed3 = my_info->ed_mcm_ed_ids[4*cur_ed+2];
   ed4 = my_info->ed_mcm_ed_ids[4*cur_ed+3];

   if (ed3 != NULL_OBJID || ed4 != NULL_OBJID )
   {
     if (ed3 != NULL_OBJID)
     {
        OM_stat = om$send (msg = message Root.wild_disconnect( 
                            cm_ed_chan),
                           targetid = ed1);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     } /* if (ed3 != NULL_OBJID) */

     if (ed4 != NULL_OBJID)
     {
        OM_stat = om$send (msg = message Root.wild_disconnect( 
                            cm_ed_chan),
                           targetid = ed2);
        EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     } /* if (ed4 != NULL_OBJID) */

     if (ed3 != NULL_OBJID)
     {
       OM_stat = om$send (msg = message EMSedge.EMget_props( &mthd_stat,
                           &ed_props),
                         targetid = ed2);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

       if (ed4 == NULL_OBJID)
         cn_ed_props = (ed_props & EMED_REVERSE_CONNECT) ? 
                        EMED_REVERSE_CONNECT : NULL;
       else
         cn_ed_props = (ed_props & EMED_REVERSE_CONNECT) ? 
                        NULL : EMED_REVERSE_CONNECT;
          
     } /* if (ed3 != NULL_OBJID) */

     else 
     {
       OM_stat = om$send (msg = message EMSedge.EMget_props( &mthd_stat,
                           &ed_props),
                         targetid = ed1);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

       cn_ed_props = (ed_props & EMED_REVERSE_CONNECT) ? 
                      EMED_REVERSE_CONNECT : NULL;

     } /* else for if (ed3 != NULL_OBJID) */

     OM_stat = om$send (msg = message EMSedge.EMconnect_edges( 
                         &mthd_stat, cn_ed_props, FALSE, 
                          ed1, NULL_OBJID, NULL_OBJID, NULL),
                         targetid = ed2);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

     /* Maintain the dominant properties as before AMD : 03/15/93 */

     if ( !(ed_props & EMED_SUBORDINATE ))
     {
      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                         EMED_SUBORDINATE, EMS_O_OFF),
                       targetid = ed1);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                         EMED_SUBORDINATE, EMS_O_ON),
                       targetid = ed2);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
     }
     else
     {
      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                         EMED_SUBORDINATE, EMS_O_ON),
                       targetid = ed1);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

      OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                         EMED_SUBORDINATE, EMS_O_OFF),
                       targetid = ed2);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
     }

   } /* if (ed3 != NULL_OBJID || ed4 != NULL_OBJID ) */

 } /* for (cur_ed = 0; cur_ed < my_info->num_ed_wmv_cm; cur_ed++) */

/*
 * For each of the surfaces created during the lift operation:
 * o Erase the surface if it is not already been erased.
 * o If option is EMS_UNDO_DELETE, delete the surface.
 *   Else turn their DISPLAYABLE and LOCATABLE off.
 */

for (cur_sf = 0; cur_sf < num_cmpnt_sf; cur_sf++)
{
 if (*option & EMS_DO_DISPLAY)
 {
  sf_already_erased = FALSE;
  i = 0; 
  while (i < *display_count && !sf_already_erased)
  {
   if (IF_EQ_OBJID( (*display_ids)[i], cmpnt_sf_ids[cur_sf].objid) )
       sf_already_erased = TRUE;
   else i++;
  } /* while (i < *display_count && !sf_already_erased) */
 
  if (!sf_already_erased)
  {
     OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                         &md_env->md_env.matrix_type, 
                         md_env->md_env.matrix, &display_mode,
                         &md_env->md_id),
                        targetid = cmpnt_sf_ids[cur_sf].objid);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  } /* if (!sf_already_erased) */

 } /* if (*option & EMS_DO_DISPLAY) */

  if (delete)
  {
    OM_stat = om$send (msg = message GRgraphics.GRdelete( &mthd_stat, 
                        md_env), targetid = cmpnt_sf_ids[cur_sf].objid);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  } /* if (delete) */
  else
  {
     EFsetsfstate(&mthd_stat, cmpnt_sf_ids[cur_sf].objid, 
                  cmpnt_sf_ids[cur_sf].osnum, EMS_O_OFF);
     EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);
  } /* if (delete) */

} /* for (cur_sf = 0; cur_sf < num_cmpnt_sf; cur_sf++) */

/*
 * In case of single surface lift, the edges of the surface will
 * have common edges though they did not have common edges before
 * the lift process. If the option is EMS_UNDO_DELETE, the common
 * edges would have been deleted during their corresponding surface
 * deletion. In this case, turn off EMED_SUBORDINATE property of the edges.
 * Otherwise, disconnect the edges from their common edges and turn off
 * EMED_SUBORDINATE property.
 */

if (my_info->num_eds_wcm_eds)
{
  if (!delete)
  {
    for (i = 0; i < my_info->num_eds_wcm_eds; i++)
    {
      OM_stat = om$send (msg = message Root.wild_disconnect( 
                          cm_ed_chan),
                         targetid = my_info->ed_cm_ed_ids[2*i]);
      EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

    } /* for (i = 0; i < my_info->num_eds_wcm_eds; i++) */

  } /* if (!delete) */

  for (i = 0; i < my_info->num_eds_wcm_eds; i++)
  {
    OM_stat = om$send (msg = message EMSedge.EMset_props (&mthd_stat,
                        EMED_SUBORDINATE, EMS_O_OFF),
                       targetid = my_info->ed_cm_ed_ids[2*i]);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  } /* for (i = 0; i < my_info->num_eds_wcm_eds; i++) */

} /* if (my_info->num_eds_wcm_eds) */

/*
 * Put back the surfaces taken out during lift operation.
 * since the surfaces out should be put back at the
 * indices at the time of their removal, it is necceassy
 * to put them back in an order reverse to the one in which
 * they were taken out.
 *
 * o Connect the surface out to its owner if the composite id is
 *   not NULL_OBJID. Composite id will be NULL_OBJID in case of
 *   single sf lift process.
 * o Make it displayable and locatble.
 * o display the surface if the caller has requested.
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

       OM_stat = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                                 owner_GRid.objid, 
                                                OM_Gw_current_OS, FALSE, NULL);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      } /* if (owner_GRid.objid != NULL_OBJID) */

      /*
       * Activate the surface's loops
       */

      OM_stat = om$send (msg = message EMSboundary.EMtree_traverse (
                          &mthd_stat, message EMSloop.EMset_props (
                            &mthd_stat, EMLP_ACTIVE, EMS_O_ON),
                          MAXINT, 1, &OPP_EMSloop_class_id, TRUE, NULL,
                          NULL, NULL),
                         senderid = *sf_out,
                         p_chanselect = &sf_ls_chan); 
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

      EFsetsfstate(&mthd_stat, *sf_out, OM_Gw_current_OS, EMS_O_ON);
      EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

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
 * If the save state info is changed during deactivate process
 * and the option is EMS_UNDO_SAVE, update the save state
 * information.
 */

if (put_ssi && (*option & EMS_UNDO_SAVE) )
{
  OM_stat = om$send (msg = message EMSdpr.EMputSSI (&mthd_stat, ssi),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
}

wrapup:

if (cmpnt_sf_ids) om$dealloc (ptr = cmpnt_sf_ids);
if (ssi) om$dealloc (ptr = ssi);

EMWRAPUP (*EMmsg, OM_stat, "In EMSlift.EMlift_int_deactivate");

return (OM_stat);

}

end implementation EMSlift;

