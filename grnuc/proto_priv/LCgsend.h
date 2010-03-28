#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCgsend.I */
extern int LCgsend __((struct GRid *gs_id, struct GRmd_env *mod, struct GRlc_stack *stack));

#if defined(__cplusplus)
}
#endif


#undef __
