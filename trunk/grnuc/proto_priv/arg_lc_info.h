#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dcob/ceo_locate/arg_lc_info.I */
extern void COB_process_GRlc_info_arg __((int addr_mode, struct GRlc_info *p_lc_info, char *arg, COB_arg_union *data, int *ret_type, char *is_const));
extern int COB_process_GRid_arg __((int addr_mode, struct GRid *p_GRid, char *arg, COB_arg_union *data, int *ret_type, char *is_const));
extern int COB_process_GRmd_env_arg __((int addr_mode, struct GRmd_env *p_GRmd_env, char *arg, COB_arg_union *data, int *ret_type, char *is_const));
extern int COB_process_GRmdenv_info_arg __((int addr_mode, struct GRmdenv_info *p_GRmdenv_info, char *arg, COB_arg_union *data, int *ret_type, char *is_const));
extern int COB_process_GRparms_arg __((int addr_mode, struct GRparms *p_GRparms, char *arg, COB_arg_union *data, int *ret_type, char *is_const));
extern void COB_process_GRdpb_scale_arg __((int addr_mode, struct GRdpb_scale *p_GRdpb_scale, char *arg, COB_arg_union *data, int *ret_type, char *is_const));
extern void COB_process_IGRdisplay_arg __((int addr_mode, struct IGRdisplay *p_IGRdisplay, char *arg, COB_arg_union *data, int *ret_type, char *is_const));

#if defined(__cplusplus)
}
#endif


#undef __
