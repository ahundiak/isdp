#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRpolyconnec.I */
extern IGRlong GRpolyconnect __((IGRlong *msg, GRspacenum *osnum, GRobjid *poly_objid, GRobjid *reffile_id));

#if defined(__cplusplus)
}
#endif


#undef __
