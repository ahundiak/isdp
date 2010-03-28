#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/go1/GRbclsproj.I */
extern int jjc_get_better_lineseg __((IGRpoint range[2 ], struct IGRline_seg *line_seg, IGRpoint better_line[2 ], IGRlong *msg));

#if defined(__cplusplus)
}
#endif


#undef __
