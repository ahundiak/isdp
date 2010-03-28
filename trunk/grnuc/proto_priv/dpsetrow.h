#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpsetrow.C */
extern IGRint DPsetrow __((IGRlong *msg, IGRdouble *row, struct DPrng_off *lo, struct DPrng_off *hi));

#if defined(__cplusplus)
}
#endif


#undef __
