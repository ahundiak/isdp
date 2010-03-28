#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRelaxaxpt.c */
extern IGRboolean GRelaxaxpt __((IGRlong *msg, struct GRevent *events[], IGRshort *num_events, struct IGRbsp_curve *el));

#if defined(__cplusplus)
}
#endif


#undef __
