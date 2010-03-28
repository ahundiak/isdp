#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRcr2ptradrt.c */
extern IGRboolean GRcr2ptrad_rtr __((IGRlong *msg, struct GRrtevent *events, IGRshort *num_events, struct IGRbsp_curve *out_geom));

#if defined(__cplusplus)
}
#endif


#undef __
