#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPsvrecall.I */
extern IGRint savedvw_recall __((IGRlong *msg, IGRshort in_flag, IGRlong array_size, struct GRid *wn_grids, struct GRid *vw_grid));

#if defined(__cplusplus)
}
#endif


#undef __
