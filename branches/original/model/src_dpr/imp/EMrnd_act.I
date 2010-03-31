/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;
/*
Description
    This method activates the corresponding state by removing and adding
    loops.

Algorithm
    Get the region table
    Take out out_loops
    Put in in_loops
    Take out out_surfaces.
    Set properties of the surfaces OFF.
    Set my active bit on

Return values
    EMS_S_Success if all is well.

History
    gupta  12/04/88  Creation.
*/

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "OMmacros.h"

from EMSedge import     EMset_props;
from EMSsubbs import    EMpartolbasis;
from EMSloop import     EMtreemod,
                        EMgivenestinfo,
                        EMset_props,
                        EMget_props,
                        EMactivate_loop;
from EMSboundary import EMget_objid,
                        EMcheck_props;
from EMSloopset import  EMnesting,
                        EMtreemod;

extern OMuword OPP_EMSsubbs_class_id;

method EMactivate(IGRlong         *EMmsg;
                  IGRshort        *option;
                  struct GRmd_env *my_env;
                  GRobjid         **display_ids;
                  IGRint          *display_count)
{
  IGRlong                   stat_OM, msg;
  IGRushort                 props, ls_props, lp_props, ed_props,
                            loop_prop;
  IGRshort                  lp_option;
  IGRint                    i, j, k, l;
  OMuint                    edge_index, conn_index,
                            num_surf_ids;
  IGRboolean                is_in_list, world, delete;
  IGRboolean                action;
  GRobjid                   *lp_in, *lp_out, lpset, loop_id, *ed_in; 
  enum GRdpmode             display_mode;
  struct GRid               *surf_ids, temp_id;
  struct EMSnest_info       nesting;
  union EMSssi_table        *ssi;
  struct EMSrndssi_table    *my_info;
  struct EMSpartolbasis     partolbasis;
  OM_S_CHANSELECT           to_comps, to_owner, to_edges, to_loopset,
                            to_common_edge;

/*--------------------------------------------------------------*/

*EMmsg = EMS_S_Success;
stat_OM = OM_S_SUCCESS;

surf_ids = NULL;
ssi = NULL;
delete = (*option & EMS_UNDO_SAVE) ? FALSE : TRUE;

stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
if (! (1 & stat_OM)) goto wrapup;

temp_id.objid = my_id;
temp_id.osnum = OM_Gw_current_OS;

if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
{
  num_surf_ids = 1;
  surf_ids = (struct GRid *) om$malloc(size = sizeof(struct GRid));
  stat_OM = om$get_objid_at_index(object = me,
                                  p_chanselect = &to_comps,
                                  index = 0,
                                  objidaddr = &surf_ids[0].objid,
                                  osnumaddr = &surf_ids[0].osnum);
  EMerr_hndlr(!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);
}
else
{
  EFgetobjids (&msg, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
               OPP_EMSsubbs_class_id, NULL, 0);
  EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
}

 /*Turn surfaces back on.*/
 for (i=0; i<num_surf_ids; i++)
 { 
   EFsetsfstate(&msg, surf_ids[i].objid, surf_ids[i].osnum, EMS_O_ON);
   EMerr_hndlr(!(1 & msg), *EMmsg, msg, wrapup);     

   if (*option & EMS_DO_DISPLAY)
   {
     /*Add new surfaces to display list.*/
     EFrealloc_if_needed(&msg, display_ids, *display_count, 
                         DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
     if (!(1 & msg)) goto wrapup;
 
     (*display_ids)[*display_count] = surf_ids[i].objid;
     (*display_count)++;
   }
 }

stat_OM = om$send(msg = message EMSdpr.EMgetSSI(&msg, &ssi),
                  targetid = my_id);
EMerr_hndlr(!(1 & msg & stat_OM), *EMmsg, EMS_E_Fail, wrapup);  

/* Take out the 'out_loops' from the corresponding loopsets */

my_info = &ssi->rnd_info;
lp_out = my_info->region_out_ids;
ls_props = NULL | EMLS_NATURAL;
lp_props = NULL;
ed_props = NULL;

for(i=0; i<my_info->num_surfaces; i++)
{
  if (*option & EMS_DO_DISPLAY)
  {
    IGRint       inx;                  /*DECL*/
    IGRboolean got_it = FALSE;

    for (inx=0; inx<*display_count; inx++)
    {
      if ( (*display_ids)[inx] == my_info->surface_ids[i] )
      {
        got_it = TRUE;
        break;
      }
    }

    if (! got_it)
    {    
      display_mode = GRbehe;
 
      stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                              &my_env->md_env.matrix_type, 
                              my_env->md_env.matrix, &display_mode,
                              &my_env->md_id),
                        targetid = my_info->surface_ids[i]);
      EMerr_hndlr(!(1&stat_OM&msg), *EMmsg, msg, wrapup);
  
      EFrealloc_if_needed(&msg, display_ids, *display_count, 
                          DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
      if (!(1 & msg)) goto wrapup;
 
      (*display_ids)[*display_count] = my_info->surface_ids[i];
      (*display_count)++;
    }
  }

  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;

  if (my_info->num_regions_out[i])
  {
    stat_OM = om$send(msg = message EMSboundary.EMget_objid (&msg, 
                            &lpset),
                      senderid = my_info->surface_ids[i],
                      p_chanselect = &to_loopset);
    EMerr_hndlr(! (1 & msg & stat_OM),*EMmsg,EMS_E_LoopsetError,wrapup);
  }

  for(j=0; j<my_info->num_regions_out[i]; j++)
  {
    stat_OM = om$send(msg = message EMSloop.EMtreemod (&msg, &nesting,
                            EXTRACT, NULL),
                      targetid = *lp_out);
    EMerr_hndlr(! (1 & msg & stat_OM),*EMmsg,EMS_E_NestError,wrapup);

    lp_option = EMS_O_OFF;
       
    props = EMLP_ACTIVE;
    stat_OM = om$send(msg = message EMSloop.EMset_props(&msg, props,
                            lp_option),
                      targetid = *lp_out);
    if (! (1 & stat_OM & msg)) goto wrapup;
    lp_out++;
  }

  /* After taking out the loops removed by this state a loopset may
     become natural again. The bit of such loopsets need to be set ON
     again.
   */

  if(my_info->num_regions_out[i])
  {
    stat_OM = om$send(msg = message EMSboundary.EMcheck_props(&msg,
                            &ls_props, &lp_props, &ed_props), 
                      targetid = lpset);
    EMerr_hndlr(!(1&msg&stat_OM),*EMmsg,EMS_E_LoopsetError,wrapup);
  }
}

/* Put in the 'in_loops' into the respective loopsets */

lp_in = my_info->region_in_ids;
lp_props = NULL;
ed_props = NULL;

for(i=0; i<my_info->num_surfaces; i++)
{
  is_in_list = FALSE;
  lp_out = my_info->region_out_ids;

  for (k=0; k<my_info->num_surfaces; k++)
  {
    for (l=0; l<my_info->num_regions_out[k]; l++)
    {
      if (*lp_in == *lp_out)
      {
        is_in_list = TRUE;
        break;
      }
      lp_out++;
    }
  }
  if (is_in_list)
  {
    /*lp_in++; THIS IS A BUG!*/
    lp_in += my_info->num_regions_in[i];
    continue;
  }

  ls_props = NULL | EMLS_NATURAL;

  if (my_info->num_regions_in[i])
  {
    world = TRUE;

    stat_OM = om$send(msg = message EMSsubbs.EMpartolbasis (&msg,
                            &my_env->md_env.matrix_type,
                            my_env->md_env.matrix, &world, FALSE,
                            &partolbasis.tol),
                      targetid = my_info->surface_ids[i]);
    EMerr_hndlr(! (1 & msg & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

    partolbasis.mattyp = &my_env->md_env.matrix_type;
    partolbasis.mat = my_env->md_env.matrix;
    partolbasis.in_world = TRUE;
    partolbasis.is_valid = TRUE;

    stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg,
                            &lpset),
                      senderid = my_info->surface_ids[i],
                      p_chanselect = &to_loopset);
    EMerr_hndlr(! (1 & msg & stat_OM),*EMmsg,EMS_E_LoopsetError,wrapup);
  }

  for(j=0; j<my_info->num_regions_in[i]; j++)
  {
    stat_OM = om$send(msg = message EMSloop.EMactivate_loop(&msg), 
                      targetid = *lp_in);
    if (! (1 & stat_OM & msg)) goto wrapup;

    stat_OM = om$send(msg = message EMSloop.EMgivenestinfo(&msg,
                            &nesting),
                      targetid= *lp_in);
    EMerr_hndlr(! (1 & msg & stat_OM), *EMmsg, EMS_E_NestError,wrapup);

    stat_OM = om$send(msg = message EMSloopset.EMnesting(&msg, &nesting,
                            &partolbasis),
                      targetid=lpset);
    EMerr_hndlr(! (1 & msg & stat_OM), *EMmsg, EMS_E_NestError,wrapup);

    if (IF_EQ_OBJID (lpset, nesting.parent))
    {
      stat_OM = om$send(msg = message EMSloopset.EMtreemod(&msg,
                              &nesting, ADD_CHILD, &partolbasis),
                        targetid = lpset);
    }
    else
    {
      stat_OM = om$send(msg = message EMSloop.EMtreemod(&msg,&nesting,
                              ADD_CHILD, &partolbasis),
                        targetid = nesting.parent);
      EMerr_hndlr(!(1 & msg & stat_OM),*EMmsg,EMS_E_NestError,wrapup);
    }
    lp_in++;
  }

  /* After all the loops have been put back in the corresponding loopset
     can become natural again. If so the bit needs to be set ON.
   */

  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;

  if (my_info->num_regions_in[i])
  {
    stat_OM = om$send(msg = message EMSboundary.EMcheck_props(&msg,
                            &ls_props, &lp_props, &ed_props), 
                      targetid = lpset);
    EMerr_hndlr(! (1 & msg & stat_OM),*EMmsg,EMS_E_LoopsetError,wrapup);
  }
 }

/* 
 * Take out all the edges that were put in and put back the edges that
 * were taken out
 */

ed_in = my_info->edge_in_ids;

ed_props = NULL;

for (i=0; i<my_info->num_edges_out; i++)
 {
  if(my_info->num_edges_in[i])
   {
    if (! (1 & (stat_OM = om$is_objid_valid(objid = *ed_in))))
     {
      stat_OM = OM_S_SUCCESS;
      ed_in += my_info->num_edges_in[i];
      continue;
     }
   }

  stat_OM = EMsend_loops(&msg,
                         message EMSboundary.EMget_objid (&msg,
                         &loop_id), my_info->edge_out_ids[i], 0,
                         OM_K_MAXINT, EMLP_ACTIVE, NULL, NULL);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

  stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                         objid_c = loop_id,
                         p_chanselect = &to_edges,
                         objid = my_info->edge_out_ids[i],
                         indexaddr = &edge_index);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = om$send (msg = message Root.disconnect (to_owner,
                           loop_id, OM_Gw_current_OS, to_edges),
                     senderid = loop_id,
                     targetid = my_info->edge_out_ids[i]);
  if (! (1 & stat_OM)) goto wrapup;

  if (delete)
   {
    stat_OM = om$send (msg = message Root.delete(1),
                       targetid = my_info->edge_out_ids[i]);
    if (! (1 & stat_OM)) goto wrapup;
   }

  stat_OM = om$send(msg = message EMSloop.EMget_props(&msg, &loop_prop),
                    targetid = loop_id);
  EMerr_hndlr(!(1&stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 for (j=0; j<my_info->num_edges_in[i]; j++)   
   {
    conn_index = (loop_prop & EMLP_REVERSED) ? edge_index : 
                                               edge_index + j;
 
    stat_OM = om$send (msg = message Root.connect (to_owner,
                             conn_index, loop_id, OM_Gw_current_OS,
                             to_edges, NULL),
                       targetid = *ed_in);
    if (! (1 & stat_OM)) goto wrapup;

    ed_in++;
   }

  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
  lp_props = EMLP_NATURAL | EMLP_EXTERNAL;

  stat_OM = om$send(msg = message EMSboundary.EMcheck_props(&msg,
                          &ls_props, &lp_props, &ed_props), 
                    targetid = loop_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
 }

/* 
 * Set the rounding bits ON for the edges that were rounded and their
 * common edges. For autotrim, the ids stored in rounded edges are 
 * really the surface ids that were deactivated for becoming disjoint.
 * To avoid changes in the save state table, these ids are being stored 
 * under wrong identity since there are NO rounded edges for autotrim.
 */

if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
 {
  display_mode = GRbehe;

  for (i=0; i<my_info->num_edges_rounded; i+=3)
   {
    props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    action = FALSE;

    stat_OM = om$send (msg = message GRvg.GRchgprops (&msg,
                             &action, (IGRshort *) &props),
                       targetid = my_info->rounded_edge_ids[i]);
    EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, msg, wrapup);

    stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                            &my_env->md_env.matrix_type,
                            my_env->md_env.matrix, 
                            &display_mode, 
                            &my_env->md_id),
                      targetid = my_info->rounded_edge_ids[i]);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, msg, wrapup);

    temp_id.objid = my_info->rounded_edge_ids[i+1];
    temp_id.osnum = OM_Gw_current_OS;

    stat_OM = om$send (msg = message GRconnector.GRdisconn (&msg,
                             &temp_id),
                       senderid = temp_id.objid,
                       targetid = my_info->rounded_edge_ids[i]);
    EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, msg, wrapup);
   }
 }
else
 {
  props = EMED_END_ROUNDED | EMED_BEG_ROUNDED;

  for (i=0; i<my_info->num_edges_rounded; i++)
   {
    stat_OM = om$send(msg = message EMSedge.EMset_props(&msg, props,
                            EMS_O_ON),
                      targetid = my_info->rounded_edge_ids[i]);
    stat_OM = om$send(msg = message EMSedge.EMset_props(&msg, props,
                            EMS_O_ON),
                      senderid = my_info->rounded_edge_ids[i],
                      p_chanselect = &to_common_edge);
    if (! (1 & stat_OM & msg)) goto wrapup;
   }
 }

 wrapup:
   EMWRAPUP(*EMmsg,stat_OM,"In EMSsfround.EMactivate")

   if(ssi) om$dealloc(ptr = ssi);
   if (surf_ids) om$dealloc(ptr = surf_ids);
   return(stat_OM);
}

end implementation EMSsfround;
