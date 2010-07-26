#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetctxsupe.I */
extern IGRlong GRgetctxsuper __((IGRlong *msg, struct GRid *Super_id));

#if defined(__cplusplus)
}
#endif


#undef __
