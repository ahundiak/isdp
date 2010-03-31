class implementation EMSgencompsf;

#include "REgencompsf.h"
#include "EMSasnucdef.h"

method NDattach_to_track_pt(IGRlong *EMmsg; struct GRid pt_grid;
                            struct GRid *as_grid; struct GRmd_env *md_env)
/*
Description
    If assoc type is ASfillet_by_surfaces_and_radii then
      attach track point parent to me at the end of the father channel.
    
History
    DLB  09/04/92    Creation.  
    SY   01/10/94    Add support for new fillet surface types.
*/ 
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  IGRuint        my_assoc_type;
  extern IGRlong EFattach_to_track_pt();


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, 
                          &my_assoc_type, NULL, NULL),
                    targetid = my_id);                          
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (my_assoc_type == EMS_ASfillet_by_surfaces_and_radii || 
      my_assoc_type == EMS_ASfillet_by_surfaces_and_radii_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_surfaces_and_radii_w_track_pt;

  else if (my_assoc_type == EMS_ASfillet_by_edge_radius ||
           my_assoc_type == EMS_ASfillet_by_edge_radius_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_edge_radius_w_track_pt;

  else if (my_assoc_type == EMS_ASfillet_by_edge_radii ||
           my_assoc_type == EMS_ASfillet_by_edge_radii_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_edge_radii_w_track_pt;

  else if (my_assoc_type == EMS_ASfillet_by_surface_surface_radius ||
	   my_assoc_type == EMS_ASfillet_by_surface_surface_radius_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_surface_surface_radius_w_track_pt;

  else if (my_assoc_type == EMS_ASfillet_by_surface_surface_radii ||
	   my_assoc_type == EMS_ASfillet_by_surface_surface_radii_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_surface_surface_radii_w_track_pt;

  else if (my_assoc_type == EMS_ASfillet_by_curve_surface_surface ||
	   my_assoc_type == EMS_ASfillet_by_curve_surface_surface_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_curve_surface_surface_w_track_pt;

  else if (my_assoc_type == EMS_ASfillet_by_curve_surface_radius ||
	   my_assoc_type == EMS_ASfillet_by_curve_surface_radius_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_curve_surface_radius_w_track_pt;

  else if (my_assoc_type == EMS_ASfillet_by_triple_surfaces ||
	   my_assoc_type == EMS_ASfillet_by_triple_surfaces_w_track_pt)
    my_assoc_type = EMS_ASfillet_by_triple_surfaces_w_track_pt;

  else {*EMmsg = EMS_I_InvalidSend; goto wrapup;}

  OM_stat = EFattach_to_track_pt(EMmsg, &pt_grid, my_id, OM_Gw_current_OS,
                                 as_grid,
                                 my_assoc_type, 
                                 EFtrack_pt_func_NO_STATE_PARENTS);

wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"gcs.NDatt_trac_pt")
  return (OM_stat);
}

method NDdetach_from_track_pt(IGRlong *EMmsg; struct GRid pt_grid;
                              struct GRid *as_grid; struct GRmd_env *md_env)
/*
Return values
   EMS_S_Success if all is well.

History
   DLB  09/04/92    Creation.  
*/ 
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  IGRuint        my_assoc_type, my_new_assoc_type;
  extern IGRlong EFdetach_from_track_pt();


  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, 
                          &my_assoc_type, NULL, NULL),
                    targetid = my_id);                          
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (my_assoc_type == EMS_ASfillet_by_surfaces_and_radii_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_surfaces_and_radii;

  else if (my_assoc_type == EMS_ASfillet_by_edge_radius_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_edge_radius;

  else if (my_assoc_type == EMS_ASfillet_by_edge_radii_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_edge_radii;

  else if (my_assoc_type == EMS_ASfillet_by_surface_surface_radius_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_surface_surface_radius;

  else if (my_assoc_type == EMS_ASfillet_by_surface_surface_radii_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_surface_surface_radii;

  else if (my_assoc_type == EMS_ASfillet_by_curve_surface_surface_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_curve_surface_surface;

  else if (my_assoc_type == EMS_ASfillet_by_curve_surface_radius_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_curve_surface_radius;

  else if (my_assoc_type == EMS_ASfillet_by_triple_surfaces_w_track_pt)
    my_new_assoc_type = EMS_ASfillet_by_triple_surfaces;

  else {*EMmsg = EMS_E_InvalidSend; goto wrapup;}

  OM_stat = EFdetach_from_track_pt(EMmsg, &pt_grid, my_id, OM_Gw_current_OS,
                                   as_grid, 
                                   my_assoc_type, my_new_assoc_type,
                                   EFtrack_pt_func_NO_STATE_PARENTS);

wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"gcs.NDdet_trac_pt")
  return (OM_stat);
}
end implementation EMSgencompsf;
