#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRrefpass.I */
extern int GRrefpass __((IGRlong *msg, IGRshort *mx_type, IGRmatrix matrix, struct GRmd_env *ref_env, OM_S_MESSAGE *msg_to_pass, IGRboolean *skew_flag, IGRdouble *origin, IGRdouble *vw_rotation, IGRdouble *pt1, IGRdouble *pt2, IGRboolean *clippoly_flag, IGRdouble *vw_volume, IGRmatrix master_to_ref_matrix, IGRdouble *range, IGRdouble *tolerance, GRobjid *objid, GRspacenum *osnum));

#if defined(__cplusplus)
}
#endif


#undef __
