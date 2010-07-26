#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcheckplana.c */
extern IGRlong GRcheckplanar __((IGRlong *msg, struct IGRpolyline *polyline, struct GRpost_info *post_info, IGRboolean *planar));

#if defined(__cplusplus)
}
#endif


#undef __
