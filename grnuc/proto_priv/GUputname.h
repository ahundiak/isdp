#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/transco/GUputname.C */
extern IGRlong GUputname __((IGRlong *msg, IGRchar *name, struct GRid *object_info, struct GRmd_env *env));

#if defined(__cplusplus)
}
#endif


#undef __
