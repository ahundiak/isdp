#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcheckortho.c */
extern IGRlong GRcheckortho __((IGRlong *msg, struct IGRpolyline *polyline, struct GRpost_info *post_info, IGRboolean *ortho));

#if defined(__cplusplus)
}
#endif


#undef __
