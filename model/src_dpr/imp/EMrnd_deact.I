/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;
/*

DESCRIPTION

This method will deactivate me if I am an active state.  This is
done by changing topology and/or geometry I have saved with what
is currently active.

ALGORITHM

Get the SSI table.

Take out in_loops if option == EMS_UNDO_SAVE else delete them.

Put in out_loops.

Take out in_edges if option == EMS_UNDO_SAVE else delete them.

Put in out_edges.

Set properties in the surfaces ON.

If option == EMS_UNDO_SAVE set my active bit OFF else delete
myself.

RETURN VALUES

EMS_S_SUCCESS if all is well.

HISTORY
        02/25/93  AMD    Removed all error messages to enable
                         deactivate to proceed and return success.
        11/02/91  DLB    Fix to get added fillet surface if auto-trim case.
        04/17/88  gupta  Creation date.
*/

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSlmdef.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsubbs_class_id;

from EMSedge import     EMget_sf_edges,
                        EMset_props;
from EMSloop import     EMtreemod,
                        EMgivenestinfo,
                        EMactivate_loop,
                        EMset_props;
from EMSsubbs import    EMpartolbasis;
from EMSboundary import EMget_objid,
                        EMcheck_props;
from EMSloopset import  EMnesting,
                        EMtreemod;

method EMdeactivate (IGRlong *EMmsg;
                     IGRshort *option;
                     struct GRmd_env *my_env;
                     GRobjid **display_ids;
                     IGRint *display_count)
{
  IGRlong                  stat_OM, msg;
  IGRint                   i, j, k, l,
                           num_surf_ids;
  OMuint                   edge_index;
  IGRboolean               is_in_list, action;
  IGRboolean               world, delete;
  GRobjid                  *lp_in, *lp_out, *ed_in, loop_id, lpset;
  enum GRdpmode            display_mode;
  union EMSssi_table       *ssi;
  struct GRid              *surf_ids, temp_id;
  struct EMSrndssi_table   *my_info;
  struct EMSnest_info      nesting;
  struct EMSpartolbasis    partolbasis;
  IGRushort        props, ls_props, lp_props, ed_props;
  OM_S_CHANSELECT          to_comps, to_edges, to_owner, to_loopset,
                           to_common_edge;
  void                     EFgetobjids();
    
/*----------------------------------------------------------------------*/

*EMmsg = EMS_S_Success;
stat_OM = OM_S_SUCCESS;

surf_ids = NULL;
ssi = NULL;
delete = (*option & EMS_UNDO_SAVE) ? FALSE : TRUE;

stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
if (! (1 & stat_OM)) goto wrapup;

temp_id.objid = my_id;
temp_id.osnum = OM_Gw_current_OS;

/* Send a message to myself to get the SSI table */

stat_OM = om$send(msg = message EMSdpr.EMgetSSI(&msg, &ssi),
                  targetid = my_id);
EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);  

my_info = &ssi->rnd_info;

if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
 {
  /**
   *  DLB 11/02/91 - Get all surface not in surf modified list on ssi.  Gupta
   *                  was getting surf from inx 0 which is not now, nor has it
   *                  ever been corret.
   **/    

  OMuint ii;
  struct GRid *reject_grids;

  reject_grids = (struct GRid *) 
                 stackalloc(my_info->num_surfaces * sizeof(struct GRid));
  for(ii=0; ii<my_info->num_surfaces; ii++)
  {
    reject_grids[ii].objid = my_info->surface_ids[ii];
    reject_grids[ii].osnum = OM_Gw_current_OS;
  }

  EFgetobjids(&msg, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
              OPP_EMSsubbs_class_id, reject_grids, my_info->num_surfaces);

  if (reject_grids) stackfree(reject_grids);
 }
else
 {
  EFgetobjids (&msg, &temp_id, &to_comps, &surf_ids, &num_surf_ids, 
               OPP_EMSsubbs_class_id, NULL, 0);
 }

if (*option & EMS_DO_DISPLAY)
{
  /** Erase the surfaces that were added to the rounding dpr **/
  for (i=0; i<num_surf_ids; i++)
  { 
    IGRint     inx;                  /*DECL*/
    IGRboolean got_it = FALSE;

    display_mode = GRbehe;

    /*Has this surface already been erased?*/
    for (inx=0; inx<*display_count; inx++)
    {
      if ( (*display_ids)[inx] == surf_ids[i].objid )
      {
        got_it = TRUE;
        break;
      }
    }

    if (! got_it)
    {    
      /*Have a surface not yet erased.*/          
      stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                              &my_env->md_env.matrix_type, 
                              my_env->md_env.matrix, &display_mode,
                              &my_env->md_id),
                        targetid = surf_ids[i].objid,
                        targetos = surf_ids[i].osnum);
    }
  }
}

/** Delete/deactivate the surfaces that were added to the rounding dpr **/
for (i=0; i<num_surf_ids; i++)
{ 
  if (delete)
  {
    stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg, my_env),
                      targetid = surf_ids[i].objid,
                      targetos = surf_ids[i].osnum);
  }
  else
  {
    EFsetsfstate(&msg, surf_ids[i].objid, surf_ids[i].osnum, EMS_O_OFF);
  }
}

/*
 * Take out the 'in_loops' from the corresponding loopsets if the
 * option is SAVE. Else delete them.
 */

lp_in = my_info->region_in_ids;
lp_props = NULL;
ed_props = NULL;

for(i=0; i<my_info->num_surfaces; i++)
{
  /* Erase the surfaces that will be modified by the deact */
  if (*option & EMS_DO_DISPLAY)
  {
    IGRint     inx;                  /*DECL*/
    IGRboolean got_it = FALSE;

    display_mode = GRbehe;

    /*Has this surface already been erased?*/
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
      /*Have a surface not yet erased.*/          
      stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                              &my_env->md_env.matrix_type, 
                              my_env->md_env.matrix, &display_mode,
                              &my_env->md_id),
                        targetid = my_info->surface_ids[i]);

      /*Store this surface that was erased (modified) -DLB*/
      EFrealloc_if_needed(&msg, display_ids, *display_count, 
                          DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));

      (*display_ids)[*display_count] = my_info->surface_ids[i];
      (*display_count)++;
    }
  }    

  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;

  if (my_info->num_regions_in[i])
   {
    stat_OM = om$send(msg = message EMSboundary.EMget_objid(&msg, &lpset),
                      senderid = my_info->surface_ids[i],
                      p_chanselect = &to_loopset);
   }

  for(j=0; j<my_info->num_regions_in[i]; j++)
   {
    stat_OM = om$send(msg = message EMSloop.EMtreemod (&msg, &nesting,
                           (delete ? DELETE : EXTRACT), NULL),
                      targetid = *lp_in);

    if (! delete)
     {
      IGRshort prop_option = EMS_O_OFF;
 
      props = EMLP_ACTIVE;
      stat_OM = om$send(msg = message EMSloop.EMset_props(&msg, props,
                              prop_option),
                        targetid = *lp_in);
      if (! (1 & stat_OM & msg)) goto wrapup;
     }
 
    lp_in++;
   }

  /*
   * After taking out the loops added by this state a loopset may become
   * natural again. The bit of such loopsets need to be set ON again.
   */

  if (my_info->num_regions_in[i])
   {
    stat_OM = om$send(msg = message EMSboundary.EMcheck_props (&msg,
                            &ls_props, &lp_props, &ed_props), 
                      targetid = lpset);
   }
 }

/* Put in the 'out_loops' into the respective loopsets */

lp_out = my_info->region_out_ids;
lp_props = NULL;
ed_props = NULL;

for(i=0; i<my_info->num_surfaces; i++)
 {
  is_in_list = FALSE;
  lp_in = my_info->region_in_ids;

  for (k=0; k<my_info->num_surfaces; k++)
   {
    for (l=0; l<my_info->num_regions_in[k]; l++)
     {
      if (*lp_out == *lp_in)
       {
        is_in_list = TRUE;
        break;
       }
      lp_in++;
     }
   }
  if (is_in_list)
   {
    lp_out++;
    continue;
   }

  ls_props = NULL | EMLS_NATURAL;

  if(my_info->num_regions_out[i])
   {
    world = TRUE;
    stat_OM = om$send(msg = message EMSsubbs.EMpartolbasis (&msg,
                            &my_env->md_env.matrix_type,
                            my_env->md_env.matrix,
                            &world, FALSE, &partolbasis.tol),
                      targetid = my_info->surface_ids[i]);

    partolbasis.mattyp = &my_env->md_env.matrix_type;
    partolbasis.mat = my_env->md_env.matrix;
    partolbasis.in_world = TRUE;
    partolbasis.is_valid = TRUE;
    stat_OM = om$send(msg = message EMSboundary.EMget_objid (&msg,&lpset),
                      senderid = my_info->surface_ids[i],
                      p_chanselect = &to_loopset);
   }

  for(j=0; j<my_info->num_regions_out[i]; j++)
   {
    stat_OM = om$send(msg = message EMSloop.EMactivate_loop(&msg),
                      targetid = *lp_out);

    stat_OM = om$send(msg = message EMSloop.EMgivenestinfo(&msg,&nesting),
                      targetid = *lp_out);

    stat_OM = om$send(msg = message EMSloopset.EMnesting (&msg, &nesting,
                            &partolbasis),
                      targetid = lpset);

    if (IF_EQ_OBJID (lpset, nesting.parent))
     {
      stat_OM = om$send(msg = message EMSloopset.EMtreemod (&msg,
                              &nesting, ADD_CHILD, &partolbasis),
                        targetid = lpset);
     }
    else
     {
      stat_OM = om$send(msg = message EMSloop.EMtreemod (&msg, &nesting,
                              ADD_CHILD, &partolbasis),
                        targetid = nesting.parent);
     }
    lp_out++;
   }

  /*
   * After all the loops have been put back in the corresponding
   * loopset can become natural again. If so the bit needs to be set ON.
   */ 
  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;

  if(my_info->num_regions_out[i])
   {
    stat_OM = om$send(msg = message EMSboundary.EMcheck_props(&msg,
                            &ls_props, &lp_props, &ed_props), 
                      targetid = lpset);
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

    stat_OM = EMsend_loops(&msg,
                           message EMSboundary.EMget_objid (&msg,
                           &loop_id), *ed_in, 0, OM_K_MAXINT,
                           EMLP_ACTIVE, NULL, NULL);


    stat_OM = om$get_index(osnum_c = OM_Gw_current_OS,
                           objid_c = loop_id,
                           p_chanselect = &to_edges,
                           objid = *ed_in,
                           indexaddr = &edge_index);
   }

  stat_OM = om$send (msg = message Root.connect (to_owner,
                           edge_index, loop_id, OM_Gw_current_OS,
                           to_edges, NULL),
                     targetid = my_info->edge_out_ids[i]);

  for (j=0; j<my_info->num_edges_in[i]; j++)   
   {
    stat_OM = om$send (msg = message Root.disconnect (to_owner,
                             loop_id, OM_Gw_current_OS, to_edges),
                       senderid = loop_id,
                       targetid = *ed_in);

    if (delete)
     {
      stat_OM = om$send (msg = message Root.delete(1),
                         targetid = *ed_in);
     }
    ed_in++;
   }

  ls_props = EMLS_NATURAL | EMLS_NONMODIFIABLE;
  lp_props = EMLP_NATURAL | EMLP_EXTERNAL;

  stat_OM = om$send(msg = message EMSboundary.EMcheck_props(&msg,
                          &ls_props, &lp_props, &ed_props), 
                    targetid = loop_id);
 }

/* 
 * Set the rounding bits off for the edges that were rounded and their
 * common edges. For autotrim, the ids stored in rounded edges are 
 * really the surface ids, surface owner id and surface owner index -- in
 * that order which were removed for becoming disjoint.
 * To avoid changes in the save state table, these ids are being stored 
 * under wrong identity since there are NO rounded edges for autotrim.
 */

if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
 {
  display_mode = GRbd;

  for (i=0; i<my_info->num_edges_rounded; i+=3)
   {
    temp_id.objid = my_info->rounded_edge_ids[i+1];
    temp_id.osnum = OM_Gw_current_OS;

    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg,
                             &temp_id, 
                             (IGRlong *) &my_info->rounded_edge_ids[i+2]),
                       targetid = my_info->rounded_edge_ids[i],
                       targetos = OM_Gw_current_OS);

    props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    action = TRUE;

    stat_OM = om$send (msg = message GRvg.GRchgprops (&msg,
                             &action, (IGRshort *) &props),
                       targetid = my_info->rounded_edge_ids[i]);

    stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg, 
                            &my_env->md_env.matrix_type,
                            my_env->md_env.matrix, 
                            &display_mode, 
                            &my_env->md_id),
                      targetid = my_info->rounded_edge_ids[i]);
   }
 }
else
 {
  props = EMED_END_ROUNDED | EMED_BEG_ROUNDED;

  for (i=0; i<my_info->num_edges_rounded; i++)
   {
    stat_OM = om$send(msg = message EMSedge.EMset_props(&msg, props,
                            EMS_O_OFF),
                      targetid = my_info->rounded_edge_ids[i]);

    stat_OM = om$send(msg = message EMSedge.EMset_props(&msg, props,
                            EMS_O_OFF),
                      senderid = my_info->rounded_edge_ids[i],
                      p_chanselect = &to_common_edge);
   }
 }

 /* Delete myself if the option is so */

 if (delete && (*option & EMS_DELETE_DPR))
 {
   stat_OM = om$send(mode = OM_e_wrt_message,
                     msg = message Root.delete(1),
                     targetid = my_id);
 }

 wrapup:

    if(ssi) om$dealloc(ptr = ssi);
    if (surf_ids) om$dealloc(ptr = surf_ids);

    stat_OM = 1;
    *EMmsg = 1;

    EMWRAPUP(*EMmsg, stat_OM, "In EMSsfround.EMdeactivate")
    return(stat_OM);
}
end implementation EMSsfround;
