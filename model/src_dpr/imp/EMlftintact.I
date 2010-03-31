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
from EMSboundary import EMget_objid, EMgetsurface_info, EMtree_traverse;
from EMSloopset  import EMtreemod, EMnesting, EMset_props;
from EMSloop     import EMtreemod, EMset_props, EMactivate_loop,
                        EMgivenestinfo;
from EMSedge     import EMget_props, EMconnect_edges;

extern OMuword OPP_EMSsubbs_class_id;

method EMlift_int_activate (
IGRlong	                           *EMmsg;
IGRshort                           *option;
struct GRmd_env                    *md_env;
GRobjid                            **display_ids;
IGRint                             *display_count;
IGRdouble                          *lift_vec;
IGRint                             *num_instructions;
struct EMinstruction_table_info    *move_info)

/*
    This file contains the activate implementation needed
    for all  LIFT operations. This is to be used internally only.


History
  03/03/92    DLB Added EFfix_parent_child_relationship call to fix up
                  assoc graph when an associative surface is removed.
  RC    01/10/90        Moved ed_rpl_eds code before lp_in_out code
                        as ed_rpl_eds code make use of EMPLP_ACTIVE
                        property. This property will be turned off
                        lp_in_out code.
  DLB   07/26/88        Added to code to (re)set surface inactive bit.
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
                                   sf_ls_chan, lp_ed_chan, ed_lp_chan;

enum GRdpmode                      display_mode = GRbe;

IGRlong	                           OM_stat;
IGRlong   mthd_stat;
IGRlong   rc;

IGRint                             num_cmpnt_sf, cur_sf, i, j, k,
                                   cur_ed, old_ed_inx,  
                                   cur_lp_out, cur_lp_in,
                                   EMsend_loops();

GRobjid                            *sf_out;

IGRboolean                         put_ssi = FALSE, world, 
                                   sf_already_erased, 
                                   replace_one_by_many = TRUE;

IGRushort                  ed_props;

GRobjid                            mod_sf_id, sf_id, ls_id, lp_id, ed1, 
                                   ed2, ed3, ed4, cm_node_ed, *old_ed, 
                                   *new_eds;

extern void                        EFgetobjids(), EFrealloc_if_needed(),
                                   EFrpl_old_new_eds();


/* ************************************************************** */


OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;

ssi = NULL;
cmpnt_sf_ids = NULL;

lm_sfcmpnt_chan.type = OM_e_addr;
lm_sfcmpnt_chan.u_sel.addr = &ME.GRcmpowner->to_components;

my_GRid.objid = my_id;
my_GRid.osnum = OM_Gw_current_OS;

OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

OM_stat = EMmake_chanselect (EMSbd_owner_to_comps, &lp_ed_chan);
EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

OM_stat = EMmake_chanselect (EMSedge_to_owner, &ed_lp_chan);
EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

partolbasis.mattyp = &md_env->md_env.matrix_type;
partolbasis.mat = md_env->md_env.matrix;
partolbasis.in_world = TRUE;
partolbasis.is_valid = TRUE;
world = TRUE;

/*
 * Mark myself displayable and locatble
 */

ME.GRgraphics->properties |= (GRIS_LOCATABLE | GRIS_DISPLAYABLE);

/*
 * get the save state information table.
 */

OM_stat = om$send (msg = message EMSsfregmod.EMgetSSI ( &mthd_stat, 
                    &ssi), targetid = my_id);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

my_info = &ssi->lft_info;

/*
 * If there are any surfaces to be lifted, 
 * o Erase it if it has not already been erased.
 * o Transform it if the lift_vec is not NULL. In such a
 *   case, the surface is not transformed. This will be the
 *   case in single surface lift process.
 */

if (my_info->num_sf_lifted)
{
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
    * If the lift_vec is NULL, there is no need to
    * transform the surafce. The lift_vec will be NULL
    * in case of single surface lift
    */

   if (lift_vec)
   {   
     OM_stat = om$send (msg = message EMSsubbs.EMexeinst ( &mthd_stat,
                    lift_vec, md_env, *num_instructions,
                    &mod_sf_id, move_info),
                   targetid = my_info->sf_lifted_ids[cur_sf]);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError, wrapup);

     if (!IF_EQ_OBJID (mod_sf_id, my_info->sf_lifted_ids[cur_sf]) )
     {
        my_info->sf_lifted_ids[cur_sf] = mod_sf_id;
        put_ssi = TRUE;
        if (*option & EMS_DO_DISPLAY) (*display_ids)[i] = mod_sf_id;
     }

   } /* if (lift_vec) */

  } /* for (cur_sf = 0; cur_sf < my_info->num_sf_lifted; cur_sf++) */

} /* if (my_info->num_sf_lifted) */

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
 * change the properties of all of the surfaces constructed
 * during lift process to DISPLAYABLE and LOCATABLE. Also
 * put them in erased surfaces list if the option is EMS_DO_DISPLAY.
 */

if (num_cmpnt_sf) 
{
  for (i = 0; i < num_cmpnt_sf; i++)
  {
    EFsetsfstate(&mthd_stat, cmpnt_sf_ids[i].objid, cmpnt_sf_ids[i].osnum,
                 EMS_O_ON);
    EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  if (*option & EMS_DO_DISPLAY)
  {
    EFrealloc_if_needed(&rc, display_ids, *display_count, 
                        DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
    EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
 
    (*display_ids)[*display_count] = cmpnt_sf_ids[i].objid;
    (*display_count)++;

  } /* if (*option & EMS_DO_DISPLAY) */

  } /* for (i = 0; i < num_cmpnt_sf; i++) */

} /* if (num_cmpnt_sf) */

/*
 * Some of the edges need to be replaced by a set of edges. If
 * so, for each edge:
 * o Get the active loop of the edge.
 * o Turn off EMLP_NATURAL property of the active loop.
 * o Turn off EMLS_NATURAL property of the active loop's loopset.
 * o Get the index of the edge w.r.t. to its active loop.
 * o Connect the replacement edges to the active loop starting
 *   first replacement edge at the edge's index.
 * o Disconnect the edge from its loop.
 */

EFrpl_old_new_eds (&rc, my_info->num_eds_rplcd, my_info->ed_rplcd_ids,
                   my_info->num_eds_in, my_info->ed_in_ids, 
                   OM_Gw_current_OS, replace_one_by_many, FALSE, TRUE);
EMerr_hndlr (!(1&rc),*EMmsg,EMS_E_Fail,wrapup);

/*****************************************************************
 The following code is replaced by the above function call 
 EFrpl_old_new_eds().

old_ed = my_info->ed_rplcd_ids;
new_eds = my_info->ed_in_ids;

for (cur_ed = 0; cur_ed < my_info->num_eds_rplcd; cur_ed++, old_ed++)
{
  sts = EMsend_loops (&rc, message EMSboundary.EMget_objid (&mthd_stat,
                      &lp_id), *old_ed, NULL, OM_K_MAXINT, 
                      EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr (!(1&sts&rc&mthd_stat),*EMmsg, EMS_E_Fail,wrapup);

  OM_stat = om$send (msg = message EMSloop.EMset_props ( &mthd_stat, 
                      EMLP_NATURAL, EMS_O_OFF), targetid = lp_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

  OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info(
                      &mthd_stat, &sf_id, NULL),
                     targetid = lp_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);

  OM_stat = om$send (msg = message EMSloopset.EMset_props( &mthd_stat,
                      EMLS_NATURAL, EMS_O_OFF), 
                     senderid = sf_id, p_chanselect = &sf_ls_chan);
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  OM_stat = om$get_index ( osnum_c = OM_Gw_current_OS, objid_c = lp_id,
                           p_chanselect = &lp_ed_chan, objid = *old_ed,
                           indexaddr = &old_ed_inx);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  for (i = 0; i < my_info->num_eds_in[cur_ed]; i++, new_eds++, 
       old_ed_inx++)
  {  
    OM_stat = om$send (msg = message Root.connect( lp_ed_chan,
                        OM_K_MAXINT, *new_eds, OM_Gw_current_OS,
                        ed_lp_chan, old_ed_inx),
                       targetid = lp_id);
     EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  } 

  OM_stat = om$send (msg = message Root.disconnect( lp_ed_chan,
                      *old_ed, OM_Gw_current_OS, ed_lp_chan),
                     targetid = lp_id);
  EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

} 

***********************************************************/

/*
 * If ther are any surfaces from/to which lps were
 * removed/added,
 * o Erase the surface if it has not already been erased.
 * o Take out the loops taken out.
 * o Addded the loops added.
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

  } /* for(i = 0; i < my_info->num_regions_out[cur_sf];i++,cur_lp_out++)*/

  /* 
   * put the in_loops back into the loopset. Also, turn off
   * EMLS_NATURAL bit.
   */

  OM_stat = om$send (msg = message EMSboundary.EMget_objid( &mthd_stat,
                      &ls_id),
                   senderid = my_info->sf_affctd_ids[cur_sf],
                   p_chanselect=&sf_ls_chan);
  EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  OM_stat = om$send (msg = message EMSloopset.EMset_props (&mthd_stat,
                     EMLS_NATURAL, EMS_O_OFF), targetid = ls_id);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

  world = TRUE;
  OM_stat = om$send(msg=message EMSsubbs.EMpartolbasis( &mthd_stat,
                     &md_env->md_env.matrix_type, md_env->md_env.matrix,
                     &world, FALSE, &partolbasis.tol),
                  targetid = my_info->sf_affctd_ids[cur_sf]);
  EMerr_hndlr(!(1&mthd_stat&OM_stat),*EMmsg,EMS_E_Fail,wrapup);

  for(i=0; i< my_info->num_regions_in[cur_sf]; i++, cur_lp_in++)
  {
    OM_stat = om$send(msg = message EMSloop.EMactivate_loop( &mthd_stat),
                       targetid = my_info->region_in_ids[cur_lp_in]);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_NestError,wrapup);

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

} /* for (cur_sf = 0; cur_sf < my_info->num_sf_affected; cur_sf++) */
  
/*
 * The edges of the surface being lifted will have some of
 * their common edge connections changed.
 * Esatblish the new edge connections.
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
 * if ed3 is not NULL_OBJID, ed3 is just disconnected and its 
 * EMED_REVERSE_CONNECT is still valid w.r.t to ed1. Similar
 * is the case if ed4 is not NULL_OBJID.
 *
 * The following logic is used to establish the topology:
 *
 * o Disconnect ed1 from ed2 if ed3 or ed4 is not NULL_OBJID.
 * o If (ed3 != NULL_OBJID)
 *     Connect ed1 with ed3. ed1 will be reverse connected to ed3 if
 *     ed3's EMED_REVERSE_CONNECT bit is on. Otherwise not.
 * o If (ed4 != NULL_OBJID)
 *     Connect ed2 with ed4. ed2 will be reverse connected to ed4 if
 *     ed4's EMED_REVERSE_CONNECT bit is on. Otherwise not.
 */

 for (cur_ed = 0; cur_ed < my_info->num_eds_wcm_md; cur_ed++)
 {
   ed1 = my_info->ed_mcm_ed_ids[4*cur_ed];
   ed2 = my_info->ed_mcm_ed_ids[4*cur_ed+1];
   ed3 = my_info->ed_mcm_ed_ids[4*cur_ed+2];
   ed4 = my_info->ed_mcm_ed_ids[4*cur_ed+3];

   if (ed3 != NULL_OBJID || ed4 != NULL_OBJID )
   {
     OM_stat = om$send (msg = message Root.wild_disconnect( 
                         cm_ed_chan),
                        targetid = ed1);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

     if (ed3 != NULL_OBJID)
     {
       OM_stat = om$send (msg = message EMSedge.EMget_props( &mthd_stat,
                           &ed_props),
                         targetid = ed3);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

       OM_stat = om$send (msg = message EMSedge.EMconnect_edges( 
                          &mthd_stat, (ed_props & EMED_REVERSE_CONNECT) ? 
                          EMED_REVERSE_CONNECT : NULL, FALSE, 
                          ed1, NULL_OBJID, NULL_OBJID, NULL),
                         targetid = ed3);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     } /* if (ed3 != NULL_OBJID) */

     if (ed4 != NULL_OBJID)
     {
       OM_stat = om$send (msg = message EMSedge.EMget_props( &mthd_stat,
                           &ed_props),
                         targetid = ed4);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

       OM_stat = om$send (msg = message EMSedge.EMconnect_edges( 
                          &mthd_stat, (ed_props & EMED_REVERSE_CONNECT) ? 
                          EMED_REVERSE_CONNECT : NULL, FALSE, 
                          ed2, NULL_OBJID, NULL_OBJID, NULL),
                         targetid = ed4);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     } /* if (ed4 != NULL_OBJID) */

   } /* if (ed3 != NULL_OBJID || ed4 != NULL_OBJID ) */

 } /* for (cur_ed = 0; cur_ed < my_info->num_ed_wmv_cm; cur_ed++) */

/*
 * Common edges of some of the edges were moved.
 * The information available in the save state is
 * 1. The edge (edge1) from which the common edge was moved to 
 *    another edge (edge2).
 * 2. The edge (edge2) to which the the common edge was moved from 
 *    another edge (edge1).
 *
 * o For each pair, get the common edge of edge1. Disconnect
 *   edge1 from its common edge. Get the properties of edge2.
 *   Connect edge2 and its common edge with the
 *   reverse_connect property of edge2.
 */

for (i = 0; i < my_info->num_ed_wmv_cm; i++)
{
  OM_stat = om$send (msg = message EMSboundary.EMget_objid (&mthd_stat,
                      &cm_node_ed),
                     senderid = my_info->ed_ced_ids[2*i],
                     p_chanselect = &cm_ed_chan);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  OM_stat = om$send (msg = message Root.wild_disconnect( 
                      cm_ed_chan),
                     targetid = my_info->ed_ced_ids[2*i]);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                      &ed_props),
                     targetid = my_info->ed_ced_ids[2*i+1]);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  OM_stat = om$send (msg = message EMSedge.EMconnect_edges( 
                      &mthd_stat, (ed_props & EMED_REVERSE_CONNECT ?
                       EMED_REVERSE_CONNECT : NULL), FALSE, 
                       cm_node_ed, NULL_OBJID, NULL_OBJID, NULL),
                     targetid = my_info->ed_ced_ids[2*i+1]);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

} /* for (i = 0; i < my_info->num_ed_wmv_cm; i++) */

/*
 * In case of a single surface lift, the edges of the surface
 * were connected to common edges though these edges did
 * not have any common edges prior to lift process. Make
 * these common edge connections.
 * For each edge,
 *  o Get the edge properties of the edge.
 *  o Connect the edge to its new common edge using the reverse connect
 *    property.
 */

if (my_info->num_eds_wcm_eds)
{
  for (i = 0; i < my_info->num_eds_wcm_eds; i++)
  {
    OM_stat = om$send (msg = message EMSedge.EMget_props( &mthd_stat,
                        &ed_props),
                       targetid = my_info->ed_cm_ed_ids[2*i] );
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_EdgeError,wrapup);

    OM_stat = om$send (msg = message EMSedge.EMconnect_edges( 
                        &mthd_stat, (ed_props & EMED_REVERSE_CONNECT) ? 
                         EMED_REVERSE_CONNECT : NULL, FALSE, 
                         my_info->ed_cm_ed_ids[2*i+1], NULL_OBJID, 
                         NULL_OBJID, NULL),
                       targetid = my_info->ed_cm_ed_ids[2*i] );
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);
 
   } /* for (i = 0; i < my_info->num_eds_wcm_eds; i++) */

} /* if (my_info->num_eds_wcm_eds) */


/*
 * Some of the surfaces need to be taken out for the lift
 * operation. For each of these surfaces:
 *
 * o Erase the surface if it has not already been erased.
 * o Disconnect the surface from its owner if the owner is not NULL_OBJID.
 *   Owner will be NULL_OBJID in case of single_sf_lift process.
 * o Make it non-displayable and non-locatble.
 * o Make its loop inactive.
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
        k = 0; 
        while (k < *display_count && !sf_already_erased)
        {
          if (IF_EQ_OBJID( (*display_ids)[i], *sf_out ) )
             sf_already_erased = TRUE;
          else k++;
        } /* while (i < *display_count && !sf_already_erased) */
 
        if (!sf_already_erased)
        {
          OM_stat = om$send(msg = message GRgraphics.GRdisplay(&mthd_stat,
                         &md_env->md_env.matrix_type, 
                         md_env->md_env.matrix, &display_mode,
                         &md_env->md_id),
                        targetid = *sf_out);
          EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

        } /* if (!sf_already_erased) */

      } /* if (*option & EMS_DO_DISPLAY) */

      if (owner_GRid.objid != NULL_OBJID)
      {
       OM_stat = om$send (msg = message GRconnector.GRdisconn (&mthd_stat,
                          &owner_GRid),
                         targetid = *sf_out);
       EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

       OM_stat = EFfix_parent_child_relationship(EMmsg, *sf_out, 
                                                 owner_GRid.objid, 
                                                 OM_Gw_current_OS, TRUE, NULL);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      } /* if (owner_GRid.objid != NULL_OBJID) */

      EFsetsfstate(&mthd_stat, *sf_out, OM_Gw_current_OS, EMS_O_OFF);
      EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

      OM_stat = om$send (msg = message EMSboundary.EMtree_traverse (
                          &mthd_stat, message EMSloop.EMset_props (
                            &mthd_stat, EMLP_ACTIVE, EMS_O_OFF),
                          MAXINT, 1, &OPP_EMSloop_class_id, TRUE, NULL,
                          NULL, NULL),
                         senderid = *sf_out,
                         p_chanselect = &sf_ls_chan); 
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);

    } /* for (j = 0; j < my_info->num_surfaces_out[i]; j++, sf_out++) */

  } /* for ( i = 0; i < my_info->num_composites; i++) */

} /* if (my_info->num_composites) */

/*
 * ssi table is modified during the activate process, post it back.
 */

if ( put_ssi && (*option & EMS_UNDO_SAVE) )
{
  OM_stat = om$send (msg = message EMSdpr.EMputSSI (&mthd_stat, ssi),
                     targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
} 

wrapup:

if (cmpnt_sf_ids) om$dealloc (ptr = cmpnt_sf_ids);
if (ssi) om$dealloc (ptr = ssi);

EMWRAPUP (*EMmsg, OM_stat, "In EMSlift.EMlift_int_activate");

return (OM_stat);

}

end implementation EMSlift;

