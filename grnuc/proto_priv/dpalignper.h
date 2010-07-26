#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpalignper.C */
extern IGRint DPalignper __((IGRlong *msg, IGRlong in_flags, IGRdouble *vpn_in, IGRdouble *vup_in, IGRdouble *origin, IGRdouble *rotate, IGRdouble *matrix));

#if defined(__cplusplus)
}
#endif


#undef __
