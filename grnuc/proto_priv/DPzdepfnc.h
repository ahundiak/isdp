#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPzdepfnc.C */
extern IGRboolean DPset_zdep __((IGRlong *msg, IGRint in_flags, IGRdouble *rotate, IGRdouble *wld_to_view, IGRdouble *keyedin_depths, IGRshort num12, IGRdouble *vw_zs));
extern IGRboolean DPgetvwz_in_wld __((IGRlong *msg, IGRint in_flags, IGRdouble *rotate, IGRdouble *wld_to_view, IGRdouble *vw_zs, IGRshort num12, IGRdouble *wld_zs));

#if defined(__cplusplus)
}
#endif


#undef __
