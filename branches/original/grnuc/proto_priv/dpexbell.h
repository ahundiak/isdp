#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpexbell.C */
extern void EX_bell __((void));
extern IGRint DPsetinq_bell __((IGRint set0_inq1, IGRint *bell_value));

#if defined(__cplusplus)
}
#endif


#undef __
