#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/csrc_130/DMdat_cmpx.I */
extern int dim_dat_cmpx __((char *entry_name, struct GRid *p_ci_macro_id, struct DMdat_cmpx *p_dat_cmpx));

#if defined(__cplusplus)
}
#endif


#undef __
