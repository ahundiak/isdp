#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpaxisalign.C */
extern IGRboolean DPaxisalign __((IGRlong *mess, IGRdouble *rotation, IGRshort *axis_aligned));

#if defined(__cplusplus)
}
#endif


#undef __
