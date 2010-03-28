#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRaals2pt.C */
extern IGRboolean GRaals2pt __((IGRlong *msg, struct GRevent *events[], IGRshort *num_events, IGRdouble *angle, struct IGRbsp_curve *ls));
static IGRboolean GRaals __((IGRlong *msg, struct GRrtevent *events, IGRshort *num_events, struct IGRbsp_curve *out_geom));

#if defined(__cplusplus)
}
#endif


#undef __
