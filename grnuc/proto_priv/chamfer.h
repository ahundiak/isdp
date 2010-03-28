#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_text/chamfer.I */
extern int DMmake_chamfer_text __((OMuword osnum, struct DMtxt_str *dim_text, IGRdouble dimn_val, IGRdouble ang_val, struct DMenv_param *p_env, struct DMloc_param *p_loc, struct DMmisc_param *p_misc, struct DMstd_param *std_arr));

#if defined(__cplusplus)
}
#endif


#undef __
