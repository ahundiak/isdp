#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRfctthruref.I */
extern int GRfctthruref __((long *msg, struct GRid *ref_id, OMuword osnum, int (*fct )(), char *arg));

#if defined(__cplusplus)
}
#endif


#undef __
