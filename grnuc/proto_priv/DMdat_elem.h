#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/csrc_130/DMdat_elem.I */
extern int dim_dat_elem __((char *entry_name, struct GRid *p_ci_macro_id, struct DMdat_elem *p_dat_elem));

#if defined(__cplusplus)
}
#endif


#undef __
