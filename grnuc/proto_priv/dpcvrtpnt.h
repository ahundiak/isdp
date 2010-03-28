#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpcvrtpnt.I */
extern IGRint DPconv_pnt __((IGRlong *msg, struct DPgra_gad *wn, IGRdouble *point, IGRint *dit_pnt, IGRboolean *valid_point, GRspacenum osnum));

#if defined(__cplusplus)
}
#endif


#undef __
