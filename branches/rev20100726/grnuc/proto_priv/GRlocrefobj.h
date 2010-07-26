#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRlocrefobj.I */
extern IGRlong GRlocref_objects __((IGRlong *msg, struct GRlc_cvl *cvl, IGRlong *properties, IGRint *levels, GRobjid *objid, GRspacenum *osnum, IGRdouble *master_to_ref, IGRdouble *vw_volume, IGRdouble *vw_matrix, IGRdouble *vw_origin));

#if defined(__cplusplus)
}
#endif


#undef __
