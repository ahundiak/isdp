#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRgetranges.C */
extern IGRlong GRgetranges __((IGRlong *msg, struct GRmd_env *md_env, struct IGRcv_prism *cv_prism, IGRmatrix master_to_ref_matrix, GRobjid *ref_objid, GRobjid *poly_objid, IGRdouble *range));

#if defined(__cplusplus)
}
#endif


#undef __
