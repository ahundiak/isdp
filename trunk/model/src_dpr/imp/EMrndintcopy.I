/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMcp.h"
#include "EMSrgmod.h"

/*
 History	
     gupta : 05/01/88  Creation Date
     SM	   : 06/Jul/89 Added bdry_options and sf_options arguments
     gupta : 12/04/89 made changes for fillet with autotrim
*/

from EMSboundary import EMintcopy;

method EMintcopy(IGRlong                 *EMmsg; 
                 struct GRmd_env         *obj_mdenv;
                 struct GRmd_env         *new_mdenv; 
                 GRobjid                 *newobjid;
                 struct EMcp_info        *copy_info;
                 IGRushort       bdry_options,
                                         sf_options)
{
  IGRlong                 stat_OM, msg;
  IGRint                  j, k, l, count;
  IGRboolean              my_copy_exists;
  GRobjid                 region_in_copy, region_out_copy, edge_in_copy, 
                          owner_copy, srf_copy, edge_out_copy,
                          rounded_edge_copy;
  union	EMSssi_table      *ssi;		
  struct EMSrndssi_table  *my_info;
  void                    EMcpsearch();
  OM_S_OBJECT_LINKAGE     surf_owner;
  OM_S_CHANSELECT         to_cpx, to_comps;

 /*---------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  ssi = NULL;

  /*
   * find out if I have been already copied or not. If so, return my
   * counter part's objid and I am all done
   */
	
  EMcpsearch (&msg, my_id, newobjid, copy_info, 0, &my_copy_exists);
  EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

  if (my_copy_exists) goto wrapup;

  /* perform the work that I have to do as a composite surface */

  stat_OM = om$send(mode = OM_e_wrt_message,
                    msg = message EMScompsurf.EMintcopy(&msg, obj_mdenv,
                          new_mdenv, newobjid, copy_info, bdry_options, 
                          sf_options),	
                    targetid = my_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

  /* copy the objects used for save state purposes */

  stat_OM = om$send (msg = message EMSdpr.EMgetSSI(&msg, &ssi),
                     targetid = my_id);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

  if (ssi)
  {

  my_info = &(ssi->rnd_info);

  /* copy surfaces affected */

  if (my_info->num_surfaces)
   {
    for (l=0; l<my_info->num_surfaces; l++)
     {
      stat_OM = om$send (msg = message EMSsurface.EMintcopy(&msg,
                               obj_mdenv, new_mdenv, &srf_copy,copy_info, 
				bdry_options, sf_options),
                         targetid = my_info->surface_ids[l]);
      EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError,wrapup);

      my_info->surface_ids[l] = srf_copy;
     }
   }
  
  /* copy region_in objects */
  
  l = 0;
  for (j=0; j<my_info->num_surfaces; j++)
   { 
    for (k=0; k<my_info->num_regions_in[j]; k++, l++)
     {
      stat_OM = om$send (msg = message EMSboundary.EMintcopy(&msg, NULL,
                               obj_mdenv->md_id.osnum,
                               new_mdenv->md_id.osnum, FALSE,
                               &region_in_copy, copy_info),
                         targetid = my_info->region_in_ids[l]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
	
      my_info->region_in_ids[l] = region_in_copy;
     }
   }

  /* copy region_out objects  */

  l = 0;
  for (j=0; j<my_info->num_surfaces; j++)
   {
    for (k=0; k<my_info->num_regions_out[j]; k++, l++)
     {
      stat_OM = om$send(msg = message EMSboundary.EMintcopy(&msg, NULL,
                              obj_mdenv->md_id.osnum, 
                              new_mdenv->md_id.osnum, FALSE,
                              &region_out_copy, copy_info),
                        targetid = my_info->region_out_ids[l]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
	
      my_info->region_out_ids[l] = region_out_copy;
     }
    }

  /* copy the edge_in objects */

  l = 0;
  for (j=0; j<my_info->num_edges_out; j++)
   {
    for (k=0; k<my_info->num_edges_in[j]; k++, l++)
     {
      stat_OM = om$send (msg = message EMSboundary.EMintcopy(&msg, NULL,
                               obj_mdenv->md_id.osnum, 
                               new_mdenv->md_id.osnum, FALSE,
                               &edge_in_copy, copy_info),
                         targetid = my_info->edge_in_ids[l]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
	
      my_info->edge_in_ids[l] = edge_in_copy;
     }
   }

  /* copy edge_out objects */

  for (k=0; k<my_info->num_edges_out; k++)
   {
    stat_OM = om$send (msg = message EMSboundary.EMintcopy(&msg, NULL,
                             obj_mdenv->md_id.osnum, 
                             new_mdenv->md_id.osnum, FALSE,
                             &edge_out_copy, copy_info),
                       targetid = my_info->edge_out_ids[k]);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
	
    my_info->edge_out_ids[k] = edge_out_copy;
   }

  /* copy rounded edge objects. For fillet with autotrim, there are no
     edges involved in rounding. However, this array is being used to
     store the surface_ids removed - if the composite becomes disjoint,
     its owner id and the index of surface on to_comps channel.
  */

  if (ME.EMSsfround->operation_type == EMS_RND_AUTOTRIM)
   {
    stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_cpx);
    stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
    if (! (1 & stat_OM)) goto wrapup;

    for (k=0; k<my_info->num_edges_rounded; k+=3)
     {
      stat_OM = om$send (msg = message EMSsurface.EMintcopy(&msg,
                               obj_mdenv, new_mdenv, &srf_copy, copy_info,
                               bdry_options, sf_options),
                         targetid = my_info->rounded_edge_ids[k]);
      EMerr_hndlr(! (1 & stat_OM & msg),*EMmsg,EMS_E_SurfaceError,wrapup);

      my_info->rounded_edge_ids[k] = srf_copy;

      EMcpsearch (&msg, my_info->rounded_edge_ids[k+1], &owner_copy,
                  copy_info, 0, &my_copy_exists);
      EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

      if (my_copy_exists)
          my_info->rounded_edge_ids[k+1] = owner_copy;
     }
   }
  else
   {
    for (k=0; k<my_info->num_edges_rounded; k++)
     {
      stat_OM = om$send (msg = message EMSboundary.EMintcopy(&msg, NULL,
                               obj_mdenv->md_id.osnum, 
                               new_mdenv->md_id.osnum, FALSE,
                               &rounded_edge_copy, copy_info),
                         targetid = my_info->rounded_edge_ids[k]);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_LoopError, wrapup);
	
      my_info->rounded_edge_ids[k] = rounded_edge_copy;
     }
    }

  /* post the ssi table to the instance data of my copy */

  stat_OM = om$send (msg = message EMSdpr.EMputSSI(&msg, ssi),
                     targetid = *newobjid,
                     targetos = new_mdenv->md_id.osnum);
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
 }

wrapup:

 if (ssi) om$dealloc(ptr = ssi);
 EMWRAPUP (*EMmsg, stat_OM, "In EMSsfround.EMintcopy");
 
 return (stat_OM);
}

end implementation EMSsfround;
