#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/node/NDnodei.I */
extern int NDcontrol_parent_state __((int count, int *parent_state, int *my_state));
extern void ASmake_md_env __((GRspacenum osnum, struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
