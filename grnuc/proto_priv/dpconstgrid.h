#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/dpconstgrid.C */
extern IGRint DPconstgrid __((IGRlong *msg, struct DPgra_gad *wn, IGRint win_no, IGRint wn_min_x, IGRint wn_min_y, IGRint wn_max_x, IGRint wn_max_y));

#if defined(__cplusplus)
}
#endif


#undef __
