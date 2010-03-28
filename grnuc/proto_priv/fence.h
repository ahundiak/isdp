#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/node/fence.I */
extern int NDcopy_fence __((struct GRid *l_object, int nb_object, int *p_nbcop, struct GRmd_env *p_fr_env, struct GRmd_env *p_to_env, int dynamics, int xform));

#if defined(__cplusplus)
}
#endif


#undef __
