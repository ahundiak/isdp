#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRarcnradpts.C */
extern IGRboolean GRarcnradpts __((IGRlong *msg, struct GRevent *events[], IGRshort *num_events, IGRshort *ccw, struct IGRbsp_curve *ar));

#if defined(__cplusplus)
}
#endif


#undef __
