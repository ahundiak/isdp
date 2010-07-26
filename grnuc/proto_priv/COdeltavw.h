#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/event/COdeltavw.C */
extern IGRlong CO_ni_delta_view __((IGRlong *sts, struct GRevent *events[]));

#if defined(__cplusplus)
}
#endif


#undef __
