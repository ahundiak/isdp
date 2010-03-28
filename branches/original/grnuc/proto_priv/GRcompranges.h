#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/rfsup/GRcompranges.C */
extern IGRint GRcompranges __((IGRlong *msg, struct IGRpolygon *clip_poly, IGRdouble *vw_volume, IGRdouble *vw_origin, IGRmatrix vw_rotation, IGRmatrix ref_to_master, IGRmatrix master_to_ref, IGRdouble *ref_range, IGRdouble *master_range));

#if defined(__cplusplus)
}
#endif


#undef __
