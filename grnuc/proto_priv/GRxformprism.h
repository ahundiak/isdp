#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRxformprism.I */
extern int GRxformprism __((IGRlong *msg, struct GRmd_env *env, struct IGRcv_prism *prism, IGRmatrix matrix, IGRshort *mx_type, GRobjid *curve_objid, GRobjid *ref_objid, OM_p_CHANSELECT chan));

#if defined(__cplusplus)
}
#endif


#undef __
