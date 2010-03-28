#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRhvls2pt.C */
extern IGRboolean GRhvls2pt __((IGRlong *msg, struct GRevent *events[], IGRshort *num_events, IGRboolean *hv_flag, struct IGRbsp_curve *ls));
static IGRboolean GRhvls __((IGRlong *msg, struct GRrtevent *events, IGRshort *num_events, struct IGRbsp_curve *out_geom));

#if defined(__cplusplus)
}
#endif


#undef __
