#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcnupdrang.I */
extern int GRcnupdrange __((IGRlong *msg, IGRdouble *origin, struct IGRarc *arc, struct GRmd_env *md_info, struct GRpost_info *post_info, IGRshort *properties, GRobjid *objid));

#if defined(__cplusplus)
}
#endif


#undef __
