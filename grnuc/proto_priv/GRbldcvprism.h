#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/GRbldcvprism.C */
extern IGRint GRbuild_prism_in_design_cube __((IGRlong *msg, struct IGRbsp_curve *curve, struct IGRcv_prism *cv_prism, IGRint ortho_view, IGRdouble wld_to_vw_matrix[]));

#if defined(__cplusplus)
}
#endif


#undef __
