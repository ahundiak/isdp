#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRccschoice.I */
extern IGRboolean GRccschoice __((IGRlong *msg, IGRshort *level, struct GRrtevent *events, IGRshort *num_events, IGRboolean *view, IGRshort *ccw, IGRboolean (*router )(), struct IGRbsp_curve *geom));

#if defined(__cplusplus)
}
#endif


#undef __
