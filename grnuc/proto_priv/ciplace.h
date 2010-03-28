#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ciplace.I */
extern int ciplace __((char *cl_name, OM_S_OBJID *targetid, int target_is_string, char *args, struct GRvg_construct *ci_cnst_list, struct IGResintx *ci_text_attr));
extern int ciplace_expression __((IGRchar *cl_name, GRclassid classid, struct GRvg_construct *ci_cnst_list, struct GRas *asso_list, struct GRid *new_obj));
extern int ciplace_symbol __((IGRchar *cl_name, GRclassid classid, struct GRvg_construct *ci_cnst_list, struct GRas *asso_list, struct GRid *new_obj));
extern int ciplace_src __((char *cl_name, struct GRvg_construct *ci_cnst_list, struct GRas *asso_list, struct GRid *new_obj));
extern int ciplace_assoc __((IGRchar *cl_name, GRclassid classid, struct GRvg_construct *ci_cnst_list, struct GRas *asso_list, struct IGResintx *ci_text_attr, struct GRid *new_obj));
extern int cias_translate __((struct ASplace *args, GRspacenum construct_os, struct GRas *asso_list, struct GRid *parents, struct GRid **roots));
extern int ciexp_translate __((struct EXPplace *args, GRspacenum construct_os, struct GRas *asso_list, struct expr_attr *exp_attr));
extern int ASconic_trans __((struct IGRarc *geom, IGRdouble *cent_p, IGRdouble *start_p, IGRdouble *end_p, IGRdouble radius, IGRdouble *vn, IGRint type));
extern int ciplace_dir __((IGRchar *name_init));

#if defined(__cplusplus)
}
#endif


#undef __
