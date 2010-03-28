#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/eventsco/COsnap.I */
extern IGRint COev_pt_snap __((IGRlong *msg, struct GRid *caller, struct GRevent events[]));

#if defined(__cplusplus)
}
#endif


#undef __
