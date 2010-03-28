#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRbuildprism.C */
extern IGRint GRbuild_prism_in_wnd __((IGRlong *msg, struct GRid *window_id, struct IGRbsp_curve *curve, IGRchar *prism));

#if defined(__cplusplus)
}
#endif


#undef __
