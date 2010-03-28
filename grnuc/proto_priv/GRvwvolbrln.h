#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/misc/GRvwvolbrln.C */
extern IGRint GRvwvolbrln __((IGRlong *msg, struct GRevent *event, struct IGRline *line));

#if defined(__cplusplus)
}
#endif


#undef __
