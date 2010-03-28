#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/supfungo/GRprismhelp.C */
extern IGRint GRbuild_prism_helper __((IGRlong *msg, struct GRid *window_id, IGRdouble wld_to_vw_matrix[], IGRdouble vw_volume[], IGRdouble view_origin[], IGRdouble vw_to_wld_matrix[], IGRdouble wld_vw_volume[], IGRdouble local_to_wld_matrix[], IGRdouble wld_to_local_matrix[], IGRdouble *height));

#if defined(__cplusplus)
}
#endif


#undef __
