#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPvw_dyn.I */
extern IGRint DPdyn_func __((IGRchar *func_parm, IGRint *hwwin_no, struct DPgra_gad *curr_gg_p, IGRint *done, IGRint *state, IGRint *number_of_cycles, IGRint *unlimited_cycles, IGRint *frame_no));
extern int DPrubber_line __((IGRint win_no, IGRint *x, IGRint *y, struct DPview_wrk_t *wrk_p, IGRint erase));
extern int cursor_indexing __((struct DPview_wrk_t *wrk_p, IGRint *x, IGRint *y));

#if defined(__cplusplus)
}
#endif


#undef __
