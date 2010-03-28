#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpinqwsdep.C */
extern IGRboolean DPinqwsdep __((IGRlong *msg, struct DPws_flags *ws_flags_mem, IGRint *display_ext_mem, IGRdouble *dit_tol_mem));

#if defined(__cplusplus)
}
#endif


#undef __
