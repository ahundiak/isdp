#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/fenceco/COgetwin.C */
extern IGRint COgetwin __((IGRint *msg, struct GRmd_env *mod, struct GRid *window, IGRchar *name));

#if defined(__cplusplus)
}
#endif


#undef __
