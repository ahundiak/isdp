#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRowneradd.I */
extern int GRowneradd __((IGRlong *msg, struct GRmd_env *env, GRobjid *objid, GRspacenum *osnum, GRrange *range));

#if defined(__cplusplus)
}
#endif


#undef __