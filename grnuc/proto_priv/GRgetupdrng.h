#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetupdrng.C */
extern IGRlong GRgetupdrng __((IGRlong *msg, struct DP_information *dp_info, IGRshort *env_type, IGRdouble *env_mx, IGRdouble *scan_range));

#if defined(__cplusplus)
}
#endif


#undef __
