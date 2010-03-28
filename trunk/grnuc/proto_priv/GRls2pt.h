#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRls2pt.c */
extern IGRboolean GRls2pt __((IGRlong *msg, struct GRevent *events[], IGRshort *num_events, struct IGRbsp_curve *ls));

#if defined(__cplusplus)
}
#endif


#undef __
