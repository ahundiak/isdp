#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dprngcheck.C */
extern IGRint DPrngcheck __((IGRlong *msg, struct DPgra_gad *win, IGRint win_no, IGRdouble *rng, IGRboolean *clip));

#if defined(__cplusplus)
}
#endif


#undef __
