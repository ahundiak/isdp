#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpmtxstack.C */
extern IGRint DPpush_vwmtx __((IGRlong *msg,
 IGRmatrix matrix,
 IGRdouble scale,
 IGRint gpipe_id,
 IGRdouble *eye_pt, 
 IGRdouble *vup,
 IGRdouble *vpn ));

#if defined(__cplusplus)
}
#endif


#undef __
