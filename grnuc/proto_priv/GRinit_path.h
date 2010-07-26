#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRinit_path.C */
extern int GRinit_path __((IGRlong *msg, struct GRlc_cvl *cvl, GRobjid *objid, GRspacenum *osnum, struct GRlc_path **path, IGRint *path_position));

#if defined(__cplusplus)
}
#endif


#undef __
