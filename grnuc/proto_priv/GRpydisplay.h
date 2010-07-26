#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/go1/GRpydisplay.I */
extern IGRlong GRpydisplay __((IGRlong *msg, struct IGRpolyline *polyline, struct IGRdisplay *display_attr, enum GRdpmode *mode, struct GRid *display_info));

#if defined(__cplusplus)
}
#endif


#undef __
