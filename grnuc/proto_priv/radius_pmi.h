#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/radius_pmi.I */
extern int ASeval_radius __((IGRint count, struct GRid *list, double *radius, double *center, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
