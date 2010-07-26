#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcr3ptrt.c */
extern IGRboolean GRcr3pt_rtr __((IGRlong *msg, struct GRrtevent *events, IGRshort *num_events, struct IGRbsp_curve *out_geom));

#if defined(__cplusplus)
}
#endif


#undef __
