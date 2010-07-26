#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dperase.C */
extern IGRint DPerase __((IGRlong *msg, IGRint *win_no, struct DPdit_range *rng));

#if defined(__cplusplus)
}
#endif


#undef __
