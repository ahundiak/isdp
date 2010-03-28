#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dptxdynamics.I */
extern IGRint DPtxdynamics __((IGRint (*dyn_fun )(), IGRchar *addnal_info, IGRchar *dummy1, IGRchar *dummy2, IGRchar *dummy3));

#if defined(__cplusplus)
}
#endif


#undef __
