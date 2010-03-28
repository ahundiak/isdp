#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/ln/DYhorverln.C */
extern IGRlong DYhor_vert_line __((struct DYhor_vert_line_params *Information, struct EX_button *Cursor, IGRdouble *Matrix, struct GRid **Objects, IGRint *NumberOfObjects, struct DPele_header **Buffers, IGRint *NumberOfBuffers, IGRchar *dummy_in1, IGRchar *dummy_in2, IGRchar *dummy_in3, IGRchar **dummy_out1, IGRchar **dummy_out2, IGRchar **dummy_out3));
extern IGRlong DYrb_hor_vert_line __((struct GRevent *Events[], struct IGRdisplay *ActiveDisplay, IGRboolean *HV_Flag));

#if defined(__cplusplus)
}
#endif


#undef __
