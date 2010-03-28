#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/symbgo/GR3dlbpost.C */
extern IGRint GR3dlbvipost __((IGRlong *msg, struct GRmd_env *mod_env, IGRint view_independent, struct IGRlbsys *lbs, struct IGRlbsys *local_lbs, GRrange range));
extern IGRint GR3dlbpost __((IGRlong *msg, struct GRmd_env *mod_env, struct IGRlbsys *lbs, struct IGRlbsys *local_lbs, GRrange range));

#if defined(__cplusplus)
}
#endif


#undef __
