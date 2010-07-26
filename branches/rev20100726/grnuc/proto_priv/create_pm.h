#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/copara/create_pm.I */
extern IGRint create_param __((IGRdouble param_val, GRobjid *param_id, GRspacenum osnum, IGRlong *response, IGRchar *response_data));
extern int AScreate_pm __((IGRint *TokenList, IGRlong *input_mask, struct GRevent *grevent, IGRdouble param_val, GRobjid *param_id, GRspacenum osnum, IGRlong *response, IGRchar *response_data));
extern int ASget_param_from_string __((char *response_data, int type_generic, struct GRid *param, double *param_value, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
