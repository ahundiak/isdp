#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/COputset.C */
extern IGRint COputset __((IGRint *msg, OM_S_OBJID set, struct GRmd_env *mod, OM_S_OBJID window_id, OMuword window_os));

#if defined(__cplusplus)
}
#endif


#undef __
