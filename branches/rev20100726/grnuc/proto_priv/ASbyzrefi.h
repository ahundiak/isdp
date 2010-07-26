#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/ASbyzrefi.I */
extern int ASbyzref_eval __((IGRint *msg, struct GRid *root_grid, struct GRid *previous_grid, IGRint count, IGRdouble *matrix, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
