#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_conv/conv_dim.I */
extern IGRint DMconv_file __((void));
extern IGRint DMdelete_expr __((char path[], IGRboolean del_obj, struct GRmd_env *md_env));
extern IGRint DMget_first_13 __((IGRint *first_deleted, struct GRid *dim));
extern IGRint DMconv_cpx __((IGRint *msg, struct GRid dim_13, struct GRmd_env *md_env, struct GRid *first));
extern IGRint DMconv_dim __((IGRint *msg, struct GRid prev, IGRboolean prev_dropped, struct GRid dim, struct GRmd_env *md_env, struct GRid *new));
extern IGRint DMchg_to_grp __((struct GRid dim));
extern IGRint DMgroup_13 __((struct GRid *dim, struct GRmd_env *md_env));
extern IGRint DMfirst_compute __((IGRlong *msg, struct GRmd_env *md_env, struct GRid *new));
extern int DMconv_status __((void));
extern IGRint DMreplace_dim __((IGRint *msg, struct GRas *assoc_lis, struct GRmd_env *md_env, GRclassid new_classid, struct GRid dim));
extern IGRint DMgive_dim13_info __((struct GRid object, struct GRid *prev, IGRboolean prev_dropped, IGRint *version, struct DMid *dmgraph_id, struct GRid *win_plan, struct GRid *act_plan, struct DMconstruct *dmcnst_lis, struct IGRestx *text_attr, struct IGRlbsys *text_geom, struct GRmd_env *md_env));
extern IGRint DMget_neighbour __((IGRint *msg, IGRint way, struct GRid macroid, IGRint char_num, IGRchar *find_name, struct GRid *neighbour_id, IGRchar *neighbour_name, struct GRmd_env *md_env));
extern IGRint DM13_get_roots_attr __((IGRint *msg, IGRint version, struct GRid prev, IGRboolean prev_dropped, struct DMid *dmgraph_id, struct DMconstruct *dmcnst_lis, IGRmatrix matrix, IGRdouble axis[3 ], IGRdouble trak_pt[3 ], struct GRmd_env *md_env, struct GRas *assoc_lis, GRclassid *dim_classid));
extern IGRint DMget_parents __((struct GRid root, IGRint size, struct GRid list[], IGRint *count));
extern int DMinit_drawing __((void));
extern IGRint DMfeet_str __((IGRchar *foot_name, struct ret_struct *rst, struct GRid mac_id, struct GRid *fgrid, struct GRmd_env *md_env));
extern IGRint DMget_dim13_symb __((IGRint *msg, struct GRid dim, struct DMenv_param *par_env));
extern IGRint DMis_dim_in_rtree __((struct GRid dim, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
