#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_conv/conv_annot.I */
extern IGRint DMconv_txldr __((IGRint *msg, struct GRid grid_13, struct GRmd_env *md_env, struct GRid *p_new));
extern IGRint DMconv_txbln __((IGRint *msg, struct GRid grid_13, struct GRmd_env *md_env, struct GRid *p_new));
extern IGRint DMconv_leader __((IGRint *msg, IGRboolean flag, struct GRid grid_13, struct GRmd_env *md_env, struct GRid *p_new));
extern IGRint DMconv_gt __((IGRint *msg, struct GRid grid_13, IGRboolean leader, struct GRmd_env *md_env, struct GRid *p_new));
extern IGRint DMplace_annotation __((IGRint *msg, GRclassid an_classid, struct GRid grid_13, IGRchar *text_ftname, IGRchar *line_ftname, IGRchar *arrow_ftname, IGRdouble bln_rad, struct annot_attr *an_attr, struct GRid dim_plan, struct GRid root_1, struct GRid root_2, struct GRmd_env *md_env, struct GRid *p_new));
extern IGRint DMget_plan_from_pretend __((struct GRid pret, struct GRid *plan, struct GRmd_env *md_env));
extern IGRint DMconv_gt_text __((IGRshort *dim_type, struct GRmd_env *md_env, IGRchar *tol_type, struct IGRestx *estx, IGRshort *length, IGRchar **chstr));
extern IGRint DMget_gt_labels __((IGRchar *string, IGRint text_length, IGRchar *modifier_label, IGRchar *circular_label, IGRchar *text_input));
extern int DMadd_blanks_to_text __((char *s, char *o, short *o_len, int t_font));
extern int DMmap_tol_symbol __((IGRchar symbol_char, IGRchar *tol_type));
extern IGRint DMconv_txldr_text __((IGRshort *length, IGRchar **chstr));
extern int DMadd_single_blank __((char *e_str, short *len));

#if defined(__cplusplus)
}
#endif


#undef __
