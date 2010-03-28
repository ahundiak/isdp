#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/gopara/any_create.I */
extern int ASany_create __((struct GRmd_env *md_env, struct ret_struct *inst, int creation_flag, struct GRid *go));

#if defined(__cplusplus)
}
#endif


#undef __
