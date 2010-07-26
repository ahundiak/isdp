#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/ANutils.I */
extern IGRint GRfield_inquire __((IGRlong *msg, IGRuchar *text_string, struct IGRestx *attr, struct IGRdisplay *display_attr, struct IGRlbsys *lbsys, IGRuchar *field_num, IGRshort *type, IGRmatrix matrix, IGRshort *length, IGRuchar **contents, IGRuchar *attributes, struct extents *extents, GRrange range, struct just_pts *just_pts));
extern IGRint DMget_dit_tol __((struct GRid *win_grid, IGRdouble *dittol));
extern IGRint DMinquire_hilite __((IGRdouble *proj_pt, IGRdouble *prev_pt, IGRdouble *targetpt, IGRdouble *center, IGRdouble *src_dir, IGRdouble *src_dir1, struct DMplan_info *plan_info, struct GRid *win_grid, IGRint *hilite));
extern int DMget_annot_txt_info __((struct DMplan_info *plan_info, struct DMsenv_param *p_senv, double *txt_vec_orie, double *norm_vec, IGRshort *txt_just, double *prev_dir));
extern int DMget_direction __((IGRdouble *src_pt, IGRdouble *test_pt, IGRdouble *plane, IGRint *flag));
extern IGRint DMget_active_just __((int pos, int type, IGRdouble *pt1, IGRdouble *pt2, IGRdouble *plane, IGRshort *just, IGRchar *annot_dir));
extern int DMadd_offset_to_leader __((IGRdouble *y_orie, IGRdouble y_offset, IGRdouble *text_orig, IGRint an_posn));
extern int DMupdate_feature_fonts __((struct GRid dim_grid, struct GRmd_env *md_env));
extern int DMreplace_geom_char __((unsigned char *text_string, int index, int geom_font, int ter_font));
extern int DMupdate_weld_font __((struct GRid dim_grid, struct GRmd_env *md_env));
extern IGRint DMupdate_bln_src __((IGRint *msg, struct GRid *src, struct GRid *dim, struct GRmd_env *md_env));
extern int DMupdate_text_fonts __((IGRint dim_type, struct GRid dim_grid, OMuword osnum, struct GRmd_env *to_env));

#if defined(__cplusplus)
}
#endif


#undef __
