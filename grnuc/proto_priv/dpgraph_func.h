#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* dpgraph_func.c */
int DPset_plane_mask __((int win_no, long mask));
int DPset_foreground_color __((int win_no, unsigned long color));
int DPsync __((int win_no, int flag));
int DPhidecursor __((int win_no));
int DPshowcursor __((int win_no));
int DPget_win_vs __((int win_no, int *scr_no));

#if defined(__cplusplus)
}
#endif


#undef __
