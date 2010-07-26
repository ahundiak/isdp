#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpelem.C */
extern IGRint DPelem __((IGRlong *msg, struct DPele_header *buffer, enum GRdpmode dpmode, struct DP_information *dp_info));

#if defined(__cplusplus)
}
#endif


#undef __
