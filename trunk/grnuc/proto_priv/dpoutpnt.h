#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpoutpnt.C */
extern IGRboolean DPoutpnt __((IGRlong *message, IGRint *win_no, IGRdouble *out_buf, IGRlong *no_out_pnt, IGRdouble *depths));

#if defined(__cplusplus)
}
#endif


#undef __
