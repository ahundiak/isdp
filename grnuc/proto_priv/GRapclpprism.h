#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/ptngo/GRapclpprism.C */
extern IGRint GRbuild_cvprism __((IGRlong *msg, IGRdouble *world_to_view, IGRdouble *view_to_world, IGRdouble *origin, IGRdouble *extents, struct IGRbsp_curve *curve, struct IGRcv_prism *prism));

#if defined(__cplusplus)
}
#endif


#undef __
