#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRputsavevw.C */
extern IGRint GRputsavevw __((IGRlong *msg, struct IGRlbsys *input_lbsys, struct GRid *view_id, GRobjid *ref_id, GRspacenum *ref_osnum, IGRmatrix ref_to_master, IGRmatrix master_to_ref, IGRint *levels, IGRmatrix vw_rotation, IGRdouble *vw_origin, IGRdouble *vw_volume, IGRboolean *is_skew));

#if defined(__cplusplus)
}
#endif


#undef __
