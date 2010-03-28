#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/plotco/COgetfence.I */
extern IGRint COget_fence_range __((IGRlong *msg, struct GRmd_env *module, struct GRid *fence, struct GRid *window, IGRdouble *world_range, IGRdouble *view_range, struct IGRcv_prism **cvprism));

#if defined(__cplusplus)
}
#endif


#undef __
