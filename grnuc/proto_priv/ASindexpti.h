#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASindexpti.I */
extern int ASindex_point __((IGRint quel_cas, struct GRmd_env *md_env, struct ret_struct pardef[], struct GRid *parent, IGRdouble xbary, IGRdouble point[]));

#if defined(__cplusplus)
}
#endif


#undef __
