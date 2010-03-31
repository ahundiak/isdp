/*
  ABSTRACT

  This class represents free form surfaces. It declares messages
  and implements methods for free form placements and modifications.

 
  HISTORY

  10/13/87 : AIC : Creation Date
  11/30/87 : rlw : Renamed EMfilletsf to EMfillet_surface and reworked it.
                   Renamed EMblnd2sfs to EMblend_surface and reworked it.
                   Renamed EMblendsf_int to EMblend_surface_interior and
                   reworked it.
  12/23/87 : rlw : Removed EMlsqsurf, EMfitsurf, EMpsurf, and EMcsurf methods.
                   Added EMsurface_by_poles, EMdirect_fit_surface,
                   EMdirect_fit_surface_by_curves, and
                   EMleast_squares_fit_surface methods.
  12/29/87 : rlw : Combined, reworked, and documented change and increase
                   order methods.  Moved undocumented methods to the top
                   of the spec file.  Moved extend surface method here from
                   EMSsubbs and reworked it.
  01/05/87 : rlw : Moved bspline to bezier message back up to class EMSsubbs.
                   Renamed EMbsalign to EMalign_surface and reworked it.      
  01/18/88 : pp  : Removed EMbs3cvs from the system, as the same function can
                   be served by EMbs4cvs
  02/17/88 : rlw : Reworked the arguments to the ruled surface method.  Note
                   that this should only break those calling ruled surface
                   with control points.
  04/26/88 : rlw : Updated documentation on EMmove_cross_section() method.
                   I changed the meaning of 2 of the input arguments.
  05/30/88 : rlw : Modified fillet surface method arguments in order to
                   support variable radius fillet.
  06/29/88 : rlw : Added blend surface with 3 or 4 curves method.
  07/08/88 : rlw : Added modify surface shape message
  08/05/88 : rlw : Added surface data reduction message
  09/05/88 : rlw : Added error arguments to data reduction
                   Modified least squares fit surface documentation to
                   indicate addition of data reduction fitting technique.
  09/27/88 : rlw : Edited least squares fit surface documentation.
  11/29/88 : rlw : Modified the blend surface with 3 or 4 curves method
                   to support an arbitrary number of curves.  Since the
                   argument list changed I renamed the method.
  05/02/89 : rlw : Modified the ruled surface method.  Changed one of the
                   not_used arguments to an option flag for creation of
                   the surface.  See method description below.  Note that
                   this should not break any I/EMS code because all known
                   methods call set this arugment to 0.
  09/14/89 : SS  : Renamed EMfillet_surface to EMmkfilletsf and added the
  		   law curve support.
  10/24/89 : rlw : Added new method to place a skinning surface.
  11/17/89 : rlw : Added argument to EMmove_cross_section_normal_to_surface()
                   and renamed it to EMmove_cross_section_normal_to_sf().
  08/17/92 : Rustagi : Added a new message 'EMblend_surf_nat' which places
                       the blend surfaces along the natural boundaries taking
                       into account the continuity order of the two surfaces
                       w.r.t. the blend surface.
  01/11/93 : Jack    : Moved EMruled_surface and EMdrafted_surface from here to
                       EMSsubbs to aid in analytic surface creation.
*/

class specification EMSgenbs (1:0) of EMSsubbs;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMinsktln
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRint numu;
  IGRdouble *uparms;
  IGRint numv;
  IGRdouble *vparms;
  IGRint mul;
  IGRint option;
  IGRboolean is_udir;
  IGRboolean is_vdir;
  GRobjid *newid;
);

message EMextend_surface
(
  struct GRlc_info *lc_info;
  IGRpoint side_point;
  IGRpoint extension_point;
  IGRlong option;
  IGRlong *msg;
);

message EMmodify_order
(
  IGRboolean increase_it;
  struct GRlc_info *lc_info;
  IGRlong u_order;
  IGRlong v_order;
  IGRlong *msg;
);

message EMsurface_by_poles
(
  IGRlong u_order;
  IGRlong v_order;
  IGRboolean u_periodic;
  IGRboolean v_periodic;
  IGRlong number_of_linestrings;
  struct GRlc_info linestrings[];
  struct GRvg_construct *construct_list;
);

message EMdirect_fit_surface
(
  IGRlong u_order;
  IGRlong v_order;
  IGRboolean u_periodic;
  IGRboolean v_periodic;
  IGRlong number_of_linestrings;
  struct GRlc_info linestrings[];
  struct GRvg_construct *construct_list;
);

message EMdirect_fit_surface_by_curves
(
  IGRlong v_order;
  IGRboolean v_periodic;
  IGRlong number_of_curves;
  struct GRlc_info curves[];
  struct GRvg_construct *construct_list;
);

message EMleast_squares_fit_surface
(
  IGRlong u_order;
  IGRlong v_order;
  IGRboolean u_periodic;
  IGRboolean v_periodic;
  IGRlong number_of_linestrings;
  struct GRlc_info linestrings[];
  IGRlong number_of_u_spans;
  IGRlong number_of_v_spans;
  IGRdouble *average_error;
  IGRdouble *maximum_error;
  IGRlong maximum_indicator[2];
  IGRpoint maximum_segment[2];
  struct GRvg_construct *construct_list;
);

message EMmkfilletsf
(
  IGRlong *msg;
  struct GRlc_info *surface_1;
  IGRboolean is_natural_normal_1;
  struct GRlc_info *surface_2;
  IGRboolean is_natural_normal_2;
  IGRpoint starting_point;
  IGRdouble starting_radius;
  IGRpoint ending_point;
  IGRdouble ending_radius;
  IGRdouble *dirpt;
  struct IGRbsp_curve *lawcv;
  IGRdouble rho;
  struct GRvg_construct *construct_list;
  IGRushort options;
);

message EMblend_surface_interior
(
  struct GRlc_info *surface_1;
  struct GRlc_info *curve_1;
  IGRvector blend_direction_1;
  IGRshort alignment_1;
  struct GRlc_info *surface_2;
  struct GRlc_info *curve_2;
  IGRvector blend_direction_2;
  IGRshort alignment_2;
  struct GRvg_construct *construct_list;
);

message EMblend_surf_nat
(
  struct GRlc_info *surface_1;
  IGRshort side_1;
  IGRboolean is_side_reversed_1;
  IGRpoint blend_direction_1;
  IGRint conti1;
  IGRdouble ratio1;
  struct GRlc_info *surface_2;
  IGRshort side_2;
  IGRboolean is_side_reversed_2;
  IGRpoint blend_direction_2;
  IGRint conti2;
  IGRdouble ratio2;
  struct GRvg_construct *construct_list;
);

message EMblend_surface
(
  struct GRlc_info *surface_1;
  IGRshort side_1;
  IGRboolean is_side_reversed_1;
  IGRpoint blend_direction_1;
  struct GRlc_info *surface_2;
  IGRshort side_2;
  IGRboolean is_side_reversed_2;
  IGRpoint blend_direction_2;
  struct GRvg_construct *construct_list;
);

message EMboxby4
(
  struct GRvg_construct *construct_list;
  double points[4][3];
  int *msg;
);

message EMmove_cross_section_normal_to_sf
(
  IGRlong *msg;
  IGRboolean *was_curve_on_surface;
  struct GRvg_construct *arglist;
  struct GRlc_info *surface;
  struct GRlc_info *trace;
  struct GRlc_info *cross_section;
  IGRpoint side_pnt;
  IGRpoint ref_pnt;
  IGRboolean is_left_hand_system;
  IGRdouble *rotation_matrix;
  IGRpoint vector_pnts[2];
  IGRpoint absolute_pnts[2];
);

message EMnetwork_of_curves
(
  IGRlong *msg;
  struct GRvg_construct *arglist;
  IGRlong number_of_u_sections;
  struct GRlc_info u_sections[];
  IGRlong number_of_v_sections;
  struct GRlc_info v_sections[];
);

message EMmerge_surfaces
(
  IGRlong number_of_surfaces;
  struct GRlc_info surfaces[];
  struct GRvg_construct *construct_list;
  IGRlong *msg;
);

message EMmove_cross_section
(
  IGRlong *msg;
  struct GRvg_construct *arglist;
  IGRlong number_of_cross_sections;
  struct GRlc_info cs[];
  IGRlong number_of_trace_curves;
  struct GRlc_info tr[];
  IGRboolean is_scaling_desired;
  IGRboolean are_sections_on_site;
  IGRpoint cross_section_origins[];
  IGRdouble *rotation_matrix;
  IGRpoint x_direction_point;
  IGRpoint y_direction_point;
);

message EMsscone
(
  struct IGRbsp_curve *curve;
  struct GRlc_info *located_curve;
  IGRpoint cone_point;
  struct GRvg_construct *construct_list;
  IGRlong *msg;
);

message EMalign_surface
(
  struct GRlc_info *my_surface;
  IGRlong my_side;
  struct GRlc_info *his_surface;
  IGRlong his_side;
  IGRlong mode;
  IGRlong *msg;
);

message EMbs4cvs
(
  IGRlong *msg;
  struct GRlc_info *located_curve1;
  struct IGRbsp_curve *curve1;
  struct GRlc_info *located_curve2;
  struct IGRbsp_curve *curve2;
  struct GRlc_info *located_curve3;
  struct IGRbsp_curve *curve3;
  struct GRlc_info *located_curve4;
  struct IGRbsp_curve *curve4;
  IGRboolean nat_side;
  struct GRvg_construct *construct_list;
);

message EMplctbesrf
(
  IGRlong *msg;
  struct GRmd_env *env;
  struct GRid crv_GRid;
  IGRdouble tube_rad;
  IGRdouble *bradii;
  struct GRvg_construct *construct_list;
);

message EMblend_3_or_more_curves
(
  IGRlong number_of_curves;
  struct GRlc_info *curves[];
  struct GRlc_info *surfaces[];
  struct GRvg_construct *construct_list;
  IGRdouble distance;
  IGRpoint center_point;
  IGRvector normal_vector;
  GRobjid *constructed_surface;
);

message EMmodify_surface_shape
(
  struct GRlc_info *lc_info;
  IGRboolean is_local_modification;
  IGRdouble point_to_modify[2];
  IGRpoint new_position;
  IGRdouble from_point[2];
  IGRdouble to_point[2];
  IGRboolean modify_in_u;
  IGRboolean preserve_u_low_tangents;
  IGRboolean preserve_u_hig_tangents;
  IGRboolean modify_in_v;
  IGRboolean preserve_v_low_tangents;
  IGRboolean preserve_v_hig_tangents;
  IGRlong *msg;
);

message EMreduced_fit_surface
(
  struct GRlc_info *lc_info;
  IGRboolean modify_in_u;
  IGRboolean preserve_u_low_tangents;
  IGRboolean preserve_u_hig_tangents;
  IGRboolean modify_in_v;
  IGRboolean preserve_v_low_tangents;
  IGRboolean preserve_v_hig_tangents;
  IGRdouble *maximum_error;
  IGRdouble *average_error;
  IGRpoint maximum_segment[2];
  IGRlong *msg;
);

message EMplace_skinning_surface
(
  IGRlong *msg;
  struct GRvg_construct *construct_list;
  IGRlong num_trace;
  struct GRlc_info trcobj[];
  IGRlong num_cross;
  struct GRlc_info crsobj[];
  IGRboolean surface_is_open;
  struct GRlc_info tangent_surfaces[4];
  IGRboolean absolute_orientation;
  IGRboolean no_height_scaling;
  struct IGRbsp_curve *shape_law;
  struct IGRbsp_curve *orient_law;
);

#endif

end specification EMSgenbs;
