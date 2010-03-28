#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpsetrng.C */
extern IGRint DPsetrng __((IGRlong *msg, IGRdouble *matrix, struct DPrange_check *range_chk));

#if defined(__cplusplus)
}
#endif


#undef __
