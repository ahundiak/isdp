#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRmodscale.C */
extern IGRint GRmodel_scale __((IGRlong *msg, GRspacenum *mf_osnum, GRspacenum *rf_osnum, IGRchar *scale_string, IGRmatrix rf_to_mf_scale_mx));
static IGRint GRparse_rfscale __((IGRchar string[], IGRdouble *rf_conv, IGRdouble *mf_conv, IGRdouble *conv));

#if defined(__cplusplus)
}
#endif


#undef __
