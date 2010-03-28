#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/expression/exp_lib.I */
extern int EXP_create_double __((char *exp_name, double exp_value, OM_S_OBJID *p_objid, OMuword osnum, OMuword *p_osnum, int type_rq, char *p_type_ob));
extern int EXP_create __((char *exp_name, char *exp_syntax, OM_S_OBJID *p_objid, OMuword osnum, OMuword *p_osnum, int type_rq, char *p_type_ob));
extern int EXP_delete_by_name __((char *exp_name, struct GRmd_env *md_env, OMuword *p_osnum));
extern int EXP_delete_by_objid __((OM_S_OBJID exp_id, OMuword osnum, struct GRmd_env *md_env));
extern int EXP_modify_by_name __((char *exp_name, char *exp_syntax, OMuword *p_osnum));
extern int EXP_modify_by_objid __((OM_S_OBJID exp_id, OMuword osnum, char *exp_syntax));
extern void Discard __((char **arg_list, IGRshort arg_num));
extern void EXP_strip __((char *string));
extern int EXP_extract_lhs_rhs __((char *exp, char *lhs, char *rhs));
extern int EXP_extract_string __((char *full_string, char *extrd_string));
extern char *EXPlocate __((char *Pattern, char *Source));
extern IGRshort EXPsubstitute __((char *old_name, char *new_name, char *expr));
extern int EXP_translate_exp __((char *expr1, OM_S_OBJID *expr_id, OMuword *p_osnum));
extern int EXP_universal_to_named __((OMuword os_num, OM_S_OBJID exp_id, char *formula, char *trans_formula, int rel_flag));
extern int EXP_named_to_universal __((OMuword os_num, OM_S_OBJID exp_id, char *formula, char *trans_formula));
extern int EXP_gen_name __((char *gnd_name, OM_S_OBJID exp_id, char *old_name));
extern int EXP_gen_suffixed_name __((char *new_name, char *old_name));
extern short int Compress_ArgList __((char **ArgList, short int *ArgCount));
extern char **Add_String __((char **array, int string_index, int string_length));
extern void Error_Function __((void (*user_fct )()));
extern void Error_Text __((int ErrNum, int *Data_pt));
extern int EXP_find_exp __((char *expr1, OM_S_OBJID *expr_id, OM_S_OBJID *owner_id, IGRshort *rc));
extern int EXP_rec_untranslate __((OM_S_OBJID objid, GRspacenum osnum, char *name));

#if defined(__cplusplus)
}
#endif


#undef __
