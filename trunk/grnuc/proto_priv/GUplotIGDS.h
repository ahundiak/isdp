#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUplotIGDS.I */
extern IGRlong GUplot_IGDS __((IGRlong *msg, IGRlong *file_name, IGRchar *dbtype, struct GRmd_env *mod_info, struct GRid *tempid_info, IGRchar seedfile[], struct GRid view_setup[], IGRdouble trans_limits[], struct IGRcv_prism *curve_prism, IGRint (*filter_function )(), IGRchar *filter_data));

#if defined(__cplusplus)
}
#endif


#undef __
