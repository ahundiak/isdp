#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/event/COpolarpts.C */
extern IGRlong CO_ni_generate_arc_pt_pattern __((IGRlong *msg, struct GRevent *events[]));

#if defined(__cplusplus)
}
#endif


#undef __
