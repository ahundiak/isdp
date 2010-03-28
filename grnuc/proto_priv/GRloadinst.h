#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRloadinst.I */
extern int GRloadinstance __((IGRlong *msg, IGRchar *scale, GRspacenum *master_osnum, GRspacenum *ref_osnum, IGRchar *filename, struct IGRlbsys *input_lbsys, struct GRid *view_id, GRobjid *ref_objid, IGRmatrix ref_to_master_matrix, IGRmatrix master_to_ref_matrix, IGRmatrix vw_matrix, IGRdouble *vw_volume, IGRint *levels, IGRdouble *vw_origin, IGRint *properties));

#if defined(__cplusplus)
}
#endif


#undef __
