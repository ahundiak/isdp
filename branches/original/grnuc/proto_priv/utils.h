#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/utils.I */
extern IGRint DMget_mea_trak __((IGRchar mea_trak, struct DMplan_info *plan_info, IGRdouble mea_axis[3 ], IGRdouble perp_axis[3 ], IGRdouble trak_dir[3 ]));
extern IGRint DMget_axis_info __((struct DMplan_info *plan_info, IGRdouble norm_to_plane[3 ], IGRdouble pt_on_plane[3 ], IGRdouble mea_axis[3 ], IGRdouble perp_axis[3 ], IGRchar mea_trak, IGRdouble trak_dir[3 ]));
extern IGRint DMget_text_info __((struct DMloc_param *par_loc, struct DMplan_info *plan_info, IGRchar mea_trak, IGRboolean leader, IGRdouble text_dir[3 ], IGRdouble offs_dir[3 ], IGRshort *just_pos, IGRshort *just_neg));
extern IGRint DMlineptpt __((IGRdouble point1[3 ], IGRdouble point2[3 ], IGRdouble line[6 ]));
extern IGRint DMlineptvec __((IGRdouble point1[3 ], IGRdouble vector[3 ], IGRdouble line[6 ]));
extern IGRint DMmake_proj_line __((IGRint *msg, IGRdouble pt1[3 ], IGRdouble pt2[3 ], IGRdouble offs, IGRdouble extn, IGRdouble line[6 ]));
extern IGRint DMmat_diff __((IGRdouble m1[16 ], IGRdouble m2[16 ]));
extern IGRint DMget_super __((OMuword md_os, OM_S_OBJID md_id, IGRboolean create, struct GRid *p_grid));
extern IGRint DMget_cur_super __((struct GRid *p_grid));
extern IGRint DMget_plan_mgr __((struct GRid *plan_mgr));
extern IGRint DMget_module_info __((struct GRmd_env *p_md_env));
extern IGRint DMget_dim_param __((IGRint type, OM_S_OBJID dim_objid, OMuword dim_osnum, struct GRid *p_grid, char *p_data));
extern IGRint DMput_dim_param __((IGRint type, OM_S_OBJID dim_objid, OMuword dim_osnum, struct GRid *p_grid, char *p_data));
extern IGRint DMget_plan_info __((OM_S_OBJID dim_id, OM_S_OBJID plan_id, OMuword osnum, struct GRmd_env *md_env, IGRmatrix win_matrix, struct DMplan_info *plan_info));
extern int DMset_dim_stan __((int *msg, int stan));
extern IGRint DMget_param_info __((IGRint type, IGRint *size, IGRint *index));
extern int DMfill_plan_info __((struct DMplan_info *plan_info));
extern IGRint DMcompute_endpt __((IGRint *msg, IGRpoint pt1, IGRpoint pt2, IGRdouble box[4 ][3 ], IGRchar txt_posn, IGRmatrix plane, struct GRmd_env *md_env, IGRpoint endpt));
extern int const_dim_line __((IGRdouble p1[3 ], IGRdouble p2[3 ], struct DMdim_line *dim_line));
extern IGRint DMget_dim_plane __((struct GRid win_grid, struct GRmd_env *md_env, struct GRid *p_grid));
extern IGRint DMget_cnv_factor __((int meas_unit, double *factor));
extern IGRint DMis_complex __((int type));
extern IGRint DMancestry_valid __((struct GRid grid, GRclassid superclassid));
extern IGRint DMextend_curve __((struct IGRbsp_curve *bsp_curve));
extern IGRint DMchange_node __((IGRboolean broadcast, IGRboolean exec_batch, struct GRid as_grid, struct GRmd_env *md_env));
extern IGRint DMcomp_obj __((struct GRid as_grid, struct GRmd_env *md_env));
extern IGRint DMget_just_pt __((IGRint *msg, IGRshort txt_just, struct IGRlbsys *txt_geom, IGRshort new_just, IGRdouble *txt_pt));
extern IGRint DMget_coord_text_info __((struct DMloc_param *par_loc, struct DMplan_info *plan_info, IGRchar mea_trak, IGRdouble proj_vec[3 ], IGRdouble text_dir[3 ], IGRdouble offs_dir[3 ], IGRshort *txt_just));
extern IGRint DMclean_data __((IGRint type, char *data));
extern IGRint DMextend_points __((IGRdouble *p1, IGRdouble *p2, IGRdouble *p3, IGRdouble *p4, IGRdouble *x_dir, IGRdouble *y_dir, IGRdouble x_off, IGRdouble y_off));
extern IGRint DMgive_formula __((struct GRid exp, char *str));
extern IGRint DMgive_value __((struct GRid exp, double *d));
extern IGRint DMcheck_edge_view __((struct GRid go_grid, struct GRid dim_plan, struct GRmd_env *md_env, IGRboolean *edge_view));
extern IGRint DMsrc_give_structure __((IGRint *msg, IGRint index, IGRint type, IGRboolean imported, IGRboolean inq0set1, OM_S_OBJID src_id, OM_S_OBJID dim_id, OMuword osnum, struct GRmd_env *md_env, struct dim_ret_struct *str));
extern IGRint DMnode_give_structure __((IGRint *msg, IGRint index, IGRint type, IGRboolean imported, OM_S_OBJID src_id, OM_S_OBJID dim_id, OMuword osnum, struct GRmd_env *md_env, struct ret_struct *str));
extern IGRint DMcompute_mea_axis __((IGRint *msg, struct GRid list[], IGRint count, IGRvector mea_axis, IGRmatrix matrix, struct GRmd_env *md_env));
extern IGRint DMget_src_info __((IGRint *msg, IGRint index, struct GRid *src_grid, struct GRid *dim_grid, struct GRmd_env *md_env));
extern IGRint DMget_index_object __((IGRint *msg, IGRboolean idx0_src1, IGRint *index, struct GRid *src_grid, struct GRid *dim_grid, struct GRmd_env *md_env));
extern IGRint DMis_displayable __((GRobjid objid, OMuword osnum));

#if defined(__cplusplus)
}
#endif


#undef __
