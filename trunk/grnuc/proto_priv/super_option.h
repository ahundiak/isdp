#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/super_para/super_option.I */
extern int AScreate_option __((GRspacenum osnum));
extern int ASbuild_name __((GRspacenum osnum, char *opt_name, char *dir_name));
extern int ASretrieve_option_obj __((GRspacenum osnum, char *opt_name, struct GRid *obj, double *val));
extern int ASretrieve_option __((GRspacenum osnum));
extern int ASsave_option __((struct GRmd_env *md_env));

#if defined(__cplusplus)
}
#endif


#undef __
