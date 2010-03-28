#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRar3pt.c */
extern IGRboolean GRar3pt __((IGRlong *msg, struct GRevent *events[], IGRshort *num_events, struct IGRbsp_curve *ar));

#if defined(__cplusplus)
}
#endif


#undef __
