#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRconnchanne.I */
extern IGRlong GRconnchannels __((IGRlong *msg, struct GRid *reffile, struct GRid *Super_id, struct GRid *context_id));

#if defined(__cplusplus)
}
#endif


#undef __
