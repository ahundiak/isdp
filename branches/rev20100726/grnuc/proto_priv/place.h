#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/place.I */
extern IGRint DMplace_dimension __((IGRint dim_type, IGRint geom_type, struct GRid *orig_grid, IGRdouble orig_pt[3 ], struct GRid *meas_grid, IGRdouble meas_pt[3 ], struct GRid *plane_grid, IGRmatrix plane_matrix, IGRint brk_pos, IGRdouble brk_dist, IGRint leader, IGRdouble lead_dist, IGRdouble trak_dist, IGRint mea_trak, IGRint mask, IGRboolean dynamics, struct GRid *owner, struct GRid *dim_grid));
extern IGRint DMchange_plane __((struct GRid *plane_grid, struct GRid *dim_grid, struct GRmd_env *md_env));
extern IGRint DMdimension_dynamics __((struct GRid dim_grid));
extern int delete_copy __((struct GRid *copy_dim, struct GRmd_env *md_env));
extern IGRint DMset_type __((IGRint type, IGRboolean update, IGRint op_code, struct GRmd_env *md_env, struct GRid *dim_grid));
extern IGRint DMplace_annot __((IGRint annot_type, IGRint geom_type, struct GRid *attach_ele1, struct GRid *attach_ele2, IGRdouble attach_pt1[3 ], IGRdouble attach_pt2[3 ], IGRint num_brkpt, IGRdouble *brkpt, IGRint text_length, IGRchar *text_string, IGRint expr_count, struct GRid *expr_list, IGRmatrix plane_matrix, struct GRid *plane_grid, struct GRid *owner, IGRint color, IGRint weight, struct GRid *dim_grid));
extern IGRint DMdmplan_set_axis __((struct GRid *win_grid, struct GRid *dim_grid, struct GRid *list, IGRint count, IGRdouble *point, struct GRmd_env *md_env));
extern IGRint DMplace_cenline __((struct GRid *go_grid, IGRdouble *point, IGRboolean position, IGRdouble *plane_matrix, struct GRid *plane_grid, struct GRid *dim_grid));
extern int DMenclose_dimtext __((IGRboolean set1_clear0, struct GRid *dim_grid, struct GRmd_env *md_env));
extern IGRint DMdisplay_dim __((enum GRdpmode mode, IGRboolean invisible_display, struct GRmd_env *md_env, struct GRid *dim_grid));

#if defined(__cplusplus)
}
#endif


#undef __
