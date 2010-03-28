#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/meas/COasctolc.I */
extern IGRint COcompute_acs_lcl_matrix __((IGRlong *msg, IGRshort module_env_matrix_type, IGRdouble *module_env_matrix, IGRshort *local_matrix_type, IGRdouble *local_matrix));

#if defined(__cplusplus)
}
#endif


#undef __
