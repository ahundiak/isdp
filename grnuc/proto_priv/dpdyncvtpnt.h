#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpdyncvtpnt.C */
extern IGRint DPdyn_conv_pnt __((IGRlong *msg, struct DPgra_gad *wn, IGRdouble *point, IGRint *dit_pnt, struct EX_button *uor_pnt, GRspacenum osnum));
extern IGRint DPis_message_disp __((void));
extern IGRint DPset_message_disp __((IGRint mes_disp));

#if defined(__cplusplus)
}
#endif


#undef __
