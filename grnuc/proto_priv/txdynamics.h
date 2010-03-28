#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/txdynamics.I */
extern IGRint DMinvoke_txdynamics __((IGRint *msg, IGRint dynamics, struct DMtxdynamics_info *dyn_info, IGRint msgkey, IGRint preproc, IGRint postproc, IGRchar pre_state, IGRchar post_state, IGRint copy, struct GRid *cp_grid, IGRint control, struct GRmd_env *md_env, struct GRevent *event, struct GRid *dim_grid));
extern IGRint DMannotdyn __((struct DMdynamics_info *info, struct EX_button *pnt, IGRboolean *pnt_flag, IGRuchar *character, IGRint num_bytes, IGRboolean *char_flag, IGRdouble *rot_matrix, struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRint *out_flags, struct DPviewind **viewind));
extern IGRint ANget_disp_par __((struct DMsenv_param *par_senv, struct ANtext_data *text_st, int font_os));

#if defined(__cplusplus)
}
#endif


#undef __
