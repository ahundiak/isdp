#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPtotnumvw.I */
extern IGRint DPtotal_num_svw __((IGRlong *msg, IGRlong *total_num, GRspacenum *osnum));

#if defined(__cplusplus)
}
#endif


#undef __
