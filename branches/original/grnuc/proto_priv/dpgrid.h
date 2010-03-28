#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpgrid.I */
extern IGRint DPgrid __((IGRlong *msg, struct DPgra_gad *wn, IGRint win_no, IGRint min_x, IGRint min_y, IGRint max_x, IGRint max_y));

#if defined(__cplusplus)
}
#endif


#undef __
