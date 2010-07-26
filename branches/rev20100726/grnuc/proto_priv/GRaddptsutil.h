#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRaddptsutil.I */
extern IGRlong GRaddptsutil __((IGRlong *msg, struct GRmd_env *env, GRspacenum *osnum, GRobjid *objid, IGRshort *num, IGRdouble *points, IGRvector vector, GRobjid *new_objid));

#if defined(__cplusplus)
}
#endif


#undef __
