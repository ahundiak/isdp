#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUiwinminmax.c */
extern void GUiget_window_min_max __((IGRchar *view_num, IGRchar *screen1, IGRchar *screen2, IGRdouble *min_x, IGRdouble *min_y, IGRdouble *max_x, IGRdouble *max_y));

#if defined(__cplusplus)
}
#endif


#undef __
