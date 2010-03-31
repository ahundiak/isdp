/*
 DESCRIPTION

   This method constructs a surface (or surfaces) which is the fillet between
   this and the other that has been passed in.

 RETURN VALUES

   msg   EMS_S_Success - on success
         EMS_E_Fail - on a non-math failure.
         EMS_E_BSerror - math function call fail.
         EMS_E_NoDynamicMemory - if no memory could be allocated
         EMS_E_InvalidArg - Some arguments are missing.

 NOTES
   
   The memory for the output fillet-surfaces array is malloced within this
   method and should be eventually freed by the caller.

 HISTORY

   18/06/90 : SS  : Modified EMfilletsf.I to make new call.
*/

class implementation EMSsubbs;

method EMgetfillet(
 IGRlong 		*msg;
 IGRshort		*mattyp;
 IGRmatrix		mat;
 IGRboolean		is_my_natural_normal;
 struct GRlc_info	*other_surface;
 IGRboolean		is_other_natural_normal;
 IGRpoint		starting_point;
 IGRdouble		starting_radius;
 IGRpoint		ending_point;
 IGRdouble		ending_radius;
 IGRdouble		*dirpt;
 struct IGRbsp_curve	*lawcv;
 IGRdouble		rho;
 struct GRvg_construct	*construct_list;
 IGRushort		options;
 IGRint 		*num_fillets;
 GRobjid		**fillets;
 IGRint                 ext_ind,cnv_ind,cnc_ind)
{
  IGRushort			opts;
  IGRlong			msg_loc,
				stat_OM;
  struct GRid			my_grid;
  struct EMSfillet_srf_info	*fillet_surfaces;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  fillet_surfaces = NULL;

  opts = NULL;
  if (is_my_natural_normal)
    opts |= EMS_RND_SF1_NATSIDE;
  if (is_other_natural_normal)
    opts |= EMS_RND_SF2_NATSIDE;
  if (ext_ind == 2)
    opts |= EMS_RND_EXTEND_SURF;
  else if (ext_ind == 1)
    opts |= EMS_RND_END_ROLLING_BALL;
  if (cnv_ind == 1)
    opts |= EMS_RND_INT_ROLLING_BALL;

  if( starting_point && ending_point && (opts & EMS_FILLET_PART))
    opts |= EMS_RND_PARTIAL_FILLET;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  stat_OM = EMcrfilletsurf (&msg_loc, opts, construct_list,
             starting_radius, ending_radius, rho, starting_point, ending_point,
             dirpt, NULL, lawcv, &my_grid, &other_surface->located_obj,
             NULL, NULL, num_fillets, fillets, NULL, NULL );

/* ret_end: */

  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMgetfillet");
  return (stat_OM);
}


end implementation EMSsubbs;
