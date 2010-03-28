#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/manipco/COdislocfun.I */
extern IGRint COhhlele __((IGRlong *msg, OM_S_OBJID caller_id, OMuword caller_os, struct GRmd_env *mod, IGRushort property));
extern IGRint COdislocfun __((IGRlong *msg, struct GRid *caller, struct GRfunction_info *info));

#if defined(__cplusplus)
}
#endif


#undef __
