#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRopenfile.I */
extern int GRopenfile __((IGRlong *msg, struct GRmd_env *md_env, GRobjid *objid, IGRchar *named_view, IGRchar *logical, GRspacenum *mod_osnum, GRobjid *mod_objid, IGRchar *osname, struct GRid *view_id, struct GRid *context));

#if defined(__cplusplus)
}
#endif


#undef __
