#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRsuperconne.I */
extern IGRlong GRsuperconnect __((IGRlong *msg, struct GRid *md_id, GRobjid *reffile_id, struct GRid *mgr_id));

#if defined(__cplusplus)
}
#endif


#undef __
