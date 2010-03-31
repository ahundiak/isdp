#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEbatch_imp.I */
extern IGRboolean VEget_needed_ids __((IGRchar *gragad_name, struct GRid *gragad, struct GRid *invis_module, struct GRid *parent, struct GRid *invis_gragad, struct GRid *invis_parent));
extern void VEsetup_invis_ve_gragad __((struct GRid *gragad, struct GRid *invis_gragad, struct GRid *parent, struct GRid *invis_parent));
extern void VEcopy_dpb_info __((struct GRid *invis_module));
extern void VEcopy_for_batch __((struct GRid *elem, OMuword elem_classid, IGRmatrix matrix, IGRshort matrix_type, struct GRmd_env *batch_env, IGRboolean composite));
extern void VEturn_all_ref_planes_off __((void));

/* VEclass_sol.I */
extern void VEclassify_edges_of_solid __((struct VEelement_header *solid));

/* VEclassify.I */
extern void VEget_components __((struct GRid *elem, IGRint *num_components, struct GRid *comp_ids));
extern void VEclassify_located_object __((struct GRid *elem, struct VEenv_info *elem_env, IGRmatrix matrix, IGRshort matrix_type, struct GRmd_env *mod_env, struct GRmd_env *batch_env, IGRboolean batch_copy, struct GRid *fence_grid, IGRshort sym_header_layer));

/* VEclip_diag.I */
extern void VEconstruct_env_objects __((struct VEenv_info *env, struct GRmd_env *batch_env));
extern void VEget_env_info_from_objects __((OMuword osnum, OM_S_OBJID clip_diag_id, OM_S_OBJID color_id, OM_S_OBJID style_id, OM_S_OBJID weight_id, struct VEenv_info *env));

/* VEestab.I */
extern void VEget_element_base_attr __((OM_S_OBJID objid, OMuword osnum, struct GRhesym *ref_symb, struct IGRdisplay *base_attr));
extern void VEdelete_soos_from_edges __((struct VEelement_header *element));
extern void VEcreate_overlapped_soos_for_edge __((struct VEelement_header *element, struct VEedge_header *edge));
extern void VEcreate_curves_for_edge __((struct VEelement_header *element, struct VEedge_header *edge, struct IGRdisplay *orig_attr));
extern void VEestablish_curves __((struct VEelement_header *element));
extern void VEoutput_hidden_edges __((struct VEelement_header *elem));

/* VEfence.I */
extern void VEprocess_fence __((OM_S_OBJID gragad_id));

/* VEget_geom.I */
extern void VEget_element_geometry __((struct VEelement_header *elem, struct VEenv_info *env));

/* VEget_env */
extern struct VEenv_info *VEget_environment_info __(( IGRint osnum, IGRmatrix mat, IGRshort mat_type, struct GRmd_env *mod_env, IGRboolean batch_copy, struct GRmd_env *batch_env ));
extern struct VEenv_info  *VEcreate_environment_for_batch __(( IGRshort osnum, IGRlong  clip_diag_id, IGRlong  color_id, IGRlong  style_id, IGRlong  weight_id ));

/* VEgetrefleve.I */
extern IGRlong VEgetreflevels __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, GRspacenum *osnum, IGRint *levels));

/* VEin_solid.I */
extern IGRboolean VEin_solid __((struct VEelement_header *element, IGRdouble uval, IGRdouble vval));

/* VElink.I */
extern IGRboolean VEfind_other_shared_edge __((IGRint edge_id_to_find, struct VEedge_header *edge_ptr, struct VEelement_header *elem, struct VEedge_header **prev_ptr, struct VEedge_header **cur_ptr));
extern IGRboolean VEfind_edge __((IGRint edge_id_to_find, IGRshort osnum, IGRshort attach_id, struct VEedge_header *edge_ptr, struct VEelement_header *elem_list, struct VEelement_header **elem_ptr, struct VEedge_header **prev_ptr, struct VEedge_header **cur_ptr));
extern void VElink_shared_edges __((struct VEelement_header *dummy_elem, struct VEelement_header *elem_list, IGRboolean *missing_link));
extern void VEcreate_dummies_for_split_pieces __((struct VEelement_header *split_elem, struct VEedge_header *split_list, struct VEedge_header *dummy_ptr, struct VEelement_header *dummy_elem));

/* VEmake_ve.I */
extern IGRlong VEmake_win_ve __((IGRlong *msg, OM_S_OBJID win_id, OMuword win_os, IGRint display_message));
extern IGRlong VEconvert_ve_win_to_wireframe __((IGRlong *msg, OM_S_OBJID win_id, OMuword win_os));

/* VEmult_trim.I */
extern void VEdetermine_visib_via_mult_trim __((struct VEelement_header *elem, IGRint *num_arr, IGRint total, IGRdouble *uv_par, IGRchar *in_solid_flags));

/* VEset_trim.I */
extern void VEdetermine_edges_that_trim_parting_lines __((struct VEelement_header *elem));

/* VEsoos.I */
extern int VEcreate_soo __((long *msg, OM_S_OBJID *p_objid, OMuword osnum, int num_surfaces, int num_curves, int resolution));
extern void VEsetup_soo_view __((OM_S_OBJID viewid, OMuword viewos));
extern void VEplace_multiple_soos __((int number_of_boundaries, double *u_parms, short span_type[], int continuous, OM_S_OBJID curve_objid, struct GRmd_env *curve_env));

/* VEsplt_class.I */
extern void VEsplit_and_classify_non_horizon_edges __((struct VEelement_header *elem_list));

/* VEtrim.I */
extern struct VEedge_header *VEtrim_polyline __((struct VEelement_header *elem, struct VEedge_header *edge, struct IGRpolyline *polyline, IGRint iso_flag));
extern IGRshort VEdetermine_point_visib_by_triming __((struct VEelement_header *elem, IGRdouble u_val, IGRdouble v_val));

/* VExsect_imp.I */
extern void VEget_object_viewing_range __((OM_S_OBJID objid, OMuword osnum, IGRmatrix matrix, IGRshort matrix_type, GRrange range));
extern void VEconstruct_sectioning_curve __((struct GRid *curve_grid, struct GRmd_env *curve_env, IGRdouble solid_range[6 ], IGRdouble proj_pt0[3 ], IGRdouble proj_pt1[3 ], IGRint save_side_dir, struct IGRbsp_curve **curve_geom));
extern void VEconstruct_solid_of_projection __((struct IGRbsp_curve *curve, IGRdouble proj_pt0[3 ], IGRdouble proj_pt1[3 ], struct IGRdisplay *active_display, IGRshort active_level, struct GRmd_env *sect_solid_env, struct GRid *solid_grid));
extern void VEdifference_solids_for_xsection __((struct GRid *sect_solid, struct GRmd_env *sect_env, struct GRid *proj_solid, struct IGRdisplay *active_display, IGRshort active_level, struct GRid *master_module_grid, struct GRid *bool_id));
extern void VEundo_xsection_booleans __((IGRint num_solids_sectioned, struct GRid *diff_grids, struct GRmd_env *solid_envs, struct GRid *proj_grids, struct GRid *master_module_grid));

/* VEedge_types.I */
extern IGRshort VEget_edge_geom_type __((OM_S_OBJID edge_id, OMuword osnum, IGRboolean standalone_curve));
extern void VEcreate_2d_curve __((struct VEedge_header *edge));
extern void VEset_split_curve_geom_type __((struct BSgeom_bsp_curve *parent_gmcurve, struct BSgeom_bsp_curve *child_gmcurve));


#if defined(__cplusplus)
}
#endif

#undef __
