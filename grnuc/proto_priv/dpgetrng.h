#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpgetrng.C */
extern IGRint DPgetrng __((IGRlong *msg, IGRdouble *matrix, struct DPrange_check *range_chk, IGRdouble *rng, IGRdouble *new_range));

#if defined(__cplusplus)
}
#endif


#undef __
