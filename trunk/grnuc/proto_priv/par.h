#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/par.I */
extern IGRint DMsplit_senv __((struct DMsenv_param *par_senv, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc));
extern IGRint DMmerge_senv __((struct DMsenv_param *par_senv, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc));
extern IGRint DMdefault_dim_stan __((void));
extern IGRint DMtxt_conv_fact __((IGRboolean flag, IGRdouble *conv_factor, IGRchar units));

#if defined(__cplusplus)
}
#endif


#undef __
