#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/event/COdeltawld.C */
extern IGRlong CO_ni_delta_world __((IGRlong *ReturnMsg, struct GRevent *Events[]));

#if defined(__cplusplus)
}
#endif


#undef __
